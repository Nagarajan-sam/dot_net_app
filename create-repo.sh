#!/bin/bash/
create_ecr_repo() {
	local docker_repo=$1
	local helm_repo=$2
	aws ecr create-repository --repository-name $docker_repo --region us-east-1
	aws ecr create-repository --repository-name $helm_repo --region us-east-1
}
create_ecr_repo "$1" "$2"
