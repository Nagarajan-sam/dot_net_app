#!/bin/bash
create_helm_package() {
  local chart_name=$1
  local app_version=$2
  local chart_version=$3
  ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
  REGION=$(aws configure get region)
  helm create $chart_name
  cd $chart_name
  echo """apiVersion: apps/v1
kind: Deployment
replicaCount: 1
image:
  repository: $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/dot-net-docker:latest
  pullPolicy: IfNotPresent
  tag: "latest"
imagePullSecrets: ["my-secret"]
nameOverride: "dot-net-app"
fullnameOverride: "dot-net-app"
serviceAccount:
  create: true
  annotations: {}
  name: "my-service-account"
podAnnotations: {}
podSecurityContext: {}
securityContext: {}
service:
  type: ClusterIP
  port: 80
ingress:
  enabled: false
  className: "dot-net-ingress"
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: "/"
          pathType: ImplementationSpecific
  tls: []
resources: {}
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
nodeSelector: {}
tolerations: []
affinity: {}""" | cat > values.yaml

  echo '''{
  "$schema": "file://./values.schema.json",
  "title": "Chart Values",
  "type": "object",
  "properties": {
    "replicaCount": {
      "type": "integer",
      "minimum": 1
    },
    "image": {
      "type": "object",
      "properties": {
        "repository": {
          "type": "string"
        },
        "pullPolicy": {
          "type": "string"
        },
        "tag": {
          "type": "string"
        }
      },
      "required": ["repository", "pullPolicy", "tag"]
    },
    "imagePullSecrets": {
      "type": "array"
    },
    "nameOverride": {
      "type": "string"
    },
    "fullnameOverride": {
      "type": "string"
    },
    "serviceAccount": {
      "type": "object",
      "properties": {
        "create": {
          "type": "boolean"
        },
        "annotations": {
          "type": "object"
        },
        "name": {
          "type": "string"
        }
      },
      "required": ["create", "annotations", "name"]
    },
    "podAnnotations": {
      "type": "object"
    },
    "podSecurityContext": {
      "type": "object"
    },
    "securityContext": {
      "type": "object"
    },
    "service": {
      "type": "object",
      "properties": {
        "type": {
          "type": "string"
        },
        "port": {
          "type": "integer"
        }
      },
      "required": ["type", "port"]
    },
    "ingress": {
      "type": "object",
      "properties": {
        "enabled": {
          "type": "boolean"
        },
        "className": {
          "type": "string"
        },
        "annotations": {
          "type": "object"
        },
        "hosts": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "host": {
                "type": "string"
              },
              "paths": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "path": {
                      "type": "string"
                    },
                    "pathType": {
                      "type": "string"
                    }
                  },
                  "required": ["path", "pathType"]
                }
              }
            },
            "required": ["host", "paths"]
          }
        },
        "tls": {
          "type": "array"
        },
        "resources": {
          "type": "object"
        }
      },
      "required": ["enabled", "className", "annotations", "hosts", "tls" ]
    },
    "autoscaling": {
      "type": "object",
      "properties": {
        "enabled": {
          "type": "boolean"
        },
        "minReplicas": {
          "type": "integer"
        },
        "maxReplicas": {
          "type": "integer"
        },
        "targetCPUUtilizationPercentage": {
          "type": "integer"
        }
      },
      "required": ["enabled", "minReplicas", "maxReplicas", "targetCPUUtilizationPercentage"]
    },
    "nodeSelector": {
      "type": "object"
    },
    "tolerations": {
      "type": "array"
    },
    "affinity": {
      "type": "object"
    }
  },
  "required": [
    "replicaCount",
    "image",
    "imagePullSecrets",
    "nameOverride",
    "fullnameOverride",
    "serviceAccount",
    "podAnnotations",
    "podSecurityContext",
    "securityContext",
    "service",
    "ingress",
    "autoscaling",
    "nodeSelector",
    "tolerations",
    "affinity"
  ]
} ''' | cat > values.schema.json

  echo "schema: values.schema.json" | cat > values.lint.yaml
  helm lint --values values.yaml
  cd ..
  kubeval $chart_name/values.yaml
  helm package --version $chart_version --app-version $app_version $chart_name
  aws ecr get-login-password --region $REGION | helm registry login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
  helm push $chart_name-$chart_version.tgz oci://$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/
}
create_helm_package "$1" "$2" "$3"
