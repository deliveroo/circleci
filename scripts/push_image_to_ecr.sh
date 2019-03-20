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

TAGS=("${CIRCLE_SHA1}")

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
    "--aws-region")
      shift
      AWS_REGION=$1
      ;;
    "--tag")
      shift
      TAGS+=("$1")
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

if [ -z "$AWS_REGION" ]; then
  echo "Please pass AWS region using --aws-region flag"
  exit 1
fi

$(aws ecr get-login --no-include-email --region $AWS_REGION)

set -ex

for TAG in "${TAGS[@]}"; do
  docker tag ${IMAGE_NAME}:${CIRCLE_SHA1} ${ECR_REPO}:${TAG}
done

for TAG in "${TAGS[@]}"; do
  retry_count=0
  while (( retry_count++ < ${MAX_RETRY_COUNT_FOR_PUSHING_DOCKER_IMAGE:-3} )); do
    docker push "${ECR_REPO}:${TAG}" && break
  done
done
