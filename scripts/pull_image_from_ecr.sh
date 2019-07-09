#!/usr/bin/env bash

set -e

if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
  echo "Please set AWS_ACCESS_KEY_ID variable in CircleCI project settings"
  exit 1
fi

if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
  echo "Please set AWS_SECRET_ACCESS_KEY variable in CircleCI project settings"
  exit 1
fi

while [ "${1}" != "" ]; do
  case "${1}" in
    "--image-name")
      shift
      IMAGE_NAME="${1}"
      ;;
    "--ecr-repo")
      shift
      ECR_REPO="${1}"
      ;;
    "--aws-region")
      shift
      AWS_REGION="${1}"
      ;;
    "--tag")
      shift
      ECR_TAG="${1}"
      ;;
    "--target-tag")
      shift
      IMAGE_TAG="${1}"
      ;;
  esac
  shift
done

if [ -z "${IMAGE_NAME}" ]; then
  echo "Please pass local image name using --image-name flag"
  exit 1
fi

if [ -z "${ECR_REPO}" ]; then
  echo "Please pass ECR repository address using --ecr-repo flag"
  exit 1
fi

if [ -z "${AWS_REGION}" ]; then
  echo "Please pass AWS region using --aws-region flag"
  exit 1
fi

if [ -z "${ECR_TAG}" ]; then
    ECR_TAG="${CIRCLE_SHA1}"
fi

if [ -z "${IMAGE_TAG}" ]; then
    IMAGE_TAG="${CIRCLE_SHA1}"
fi

$(aws ecr get-login --no-include-email --region $AWS_REGION)

set -ex

REMOTE_IMAGE="${ECR_REPO}:${ECR_TAG}"
LOCAL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

retry_count=0
while (( retry_count++ < ${MAX_RETRY_COUNT_FOR_PULLING_DOCKER_IMAGE:-3} )); do
  docker pull "${REMOTE_IMAGE}" && break
done

docker tag "${REMOTE_IMAGE}" "${LOCAL_IMAGE}"
