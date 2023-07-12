#!/bin/bash/
ACCOUNT_ID=aws sts get-caller-identity --query 'Account' --output text
REGION=aws configure get region
REPO_NAME=$1
VERSION=$2
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
docker build -t $REPO_NAME .
docker tag $REPO_NAME:$VERSION $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$VERSION
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$VERSION
