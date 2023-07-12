#!/bin/bash
create_helm_package() {
	local chart_name=$1
	local app_version=$2
	local chart_version=$3
	ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
	REGION=$(aws configure get region)
	helm create $chart_name
	helm lint $chart_name
	helm package --version $chart_version --app-version $app_version $chart_name
	aws ecr get-login-password --region $REGION | helm registry login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
	helm push $chart_name-$chart_version.tgz oci://$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/
}
create_helm_package "$1" "$2" "$3"
