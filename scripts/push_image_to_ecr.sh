#!/usr/bin/env bash

set -e

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "Please set AWS_ACCESS_KEY_ID variable in CircleCI project settings"
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Please set AWS_SECRET_ACCESS_KEY variable in CircleCI project settings"
  exit 1
fi

while [ "$1" != "" ]; do
  case $1 in
    "--image-name")
      shift
      IMAGE_NAME=$1
      ;;
    "--ecr-repo")
      shift
      ECR_REPO=$1
      ;;
  esac
  shift
done

if [ -z "$IMAGE_NAME" ]; then
  echo "Please pass local image name using --image-name flag"
  exit 1
fi

if [ -z "$ECR_REPO" ]; then
  echo "Please pass ECR repository address using --ecr-repo flag"
  exit 1
fi

$(aws ecr get-login --no-include-email)

set -ex

target=${ECR_REPO}:${CIRCLE_SHA1}
docker tag ${IMAGE_NAME}:${CIRCLE_SHA1} $target
docker push $target
