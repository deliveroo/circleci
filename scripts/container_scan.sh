#!/bin/bash

if [ -z "${SNYK_TOKEN}" ]; then
  echo "Please set SNYK_TOKEN variable in CircleCI project settings"
  exit 1
fi

if [ -z "${GITHUB_ACCESS_TOKEN}" ]; then
  echo "Please set GITHUB_ACCESS_TOKEN variable in CircleCI project settings"
  exit 1
fi

if [[ $CONTAINER_TAG ]]; then
  TAG_NAME=$CONTAINER_TAG
  echo "Tag from \$CONTAINER_TAG: $CONTAINER_TAG"
else
  TAG_NAME="latest"
fi

## auth
snyk auth ${SNYK_TOKEN}

## set project path
PROJECT_PATH=$(eval echo ${CIRCLE_WORKING_DIRECTORY})

## set tag
SNYK_FNAME=snyk.json

## lets retag the image
docker image tag ${CIRCLE_PROJECT_REPONAME}:${CIRCLE_SHA1} ${CIRCLE_PROJECT_REPONAME}:${TAG_NAME}

## test 
snyk test --docker ${CIRCLE_PROJECT_REPONAME}:${TAG_NAME} --file=${PROJECT_PATH}/Dockerfile --json > ${PROJECT_PATH}/${SNYK_FNAME}

echo "[*] Finished snyk test. Moving onto monitor"

## monitor
snyk monitor --docker ${CIRCLE_PROJECT_REPONAME}:${TAG_NAME} --file="${PROJECT_PATH}/Dockerfile"

echo "[*] Finished snyk monitoring. Checking if we need to send results to GitHub"

## parse results and check if we should comment back to GitHub
scan_results=$(parse_scan_results ${PROJECT_PATH}/${SNYK_FNAME})

[[ $scan_results ]] && comment_on_pr "$scan_results"
