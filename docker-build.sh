#!/bin/bash/
docker_build() {
	local repo_name=$1
	local app_version=$2
	ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
	REGION=$(aws configure get region)
	aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
	docker build -t $repo_name:$app_version .
	docker tag $repo_name:$app_version $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$repo_name:$app_version
	docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$repo_name:$app_version
}
docker_build "$1" "$2"
