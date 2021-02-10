#!/bin/bash

if [ -z "${SNYK_TOKEN}" ]; then
  echo "Please set SNYK_TOKEN variable in CircleCI project settings"
  exit 1
fi

if [ -z "${GITHUB_SNYK_TOKEN}" ]; then
  echo "Please set GITHUB_SNYK_TOKEN variable in CircleCI project settings"
  exit 1
fi

if [[ $CONTAINER_TAG ]]; then
  TAG_NAME=$CONTAINER_TAG
  echo "Tag from \$CONTAINER_TAG: $CONTAINER_TAG"
else
  TAG_NAME="latest"
fi

parse_and_post_comment () {
  scan_results=$(parse_scan_results $1)
  if [[ $scan_results ]]; then
      comment_on_pr "$scan_results"
  else
    echo "No scan results found in $1."
  fi
}

## auth
snyk auth ${SNYK_TOKEN}

## set project path
PROJECT_PATH=$(eval echo ${CIRCLE_WORKING_DIRECTORY})

## lets retag the image
docker image tag ${CIRCLE_PROJECT_REPONAME}:${CIRCLE_SHA1} ${CIRCLE_PROJECT_REPONAME}:${TAG_NAME}

## test container
snyk test --docker ${CIRCLE_PROJECT_REPONAME}:${TAG_NAME} --file=${PROJECT_PATH}/Dockerfile --json > "${PROJECT_PATH}/snyk-container.json"

## test app
snyk test --json > "${PROJECT_PATH}/snyk-app.json"

echo "[*] Finished snyk test. Moving onto monitor"

## monitor app
snyk monitor

## monitor container
snyk monitor --docker ${CIRCLE_PROJECT_REPONAME}:${TAG_NAME} --file="${PROJECT_PATH}/Dockerfile"

echo "[*] Finished snyk monitoring. Checking if we need to send results to GitHub"

if [[ -z "${CIRCLE_PULL_REQUEST}" ]]; then
  echo "Not a pull request. Exiting"
else
  parse_and_post_comment "${PROJECT_PATH}/snyk-container.json"
  parse_and_post_comment "${PROJECT_PATH}/snyk-app.json"
fi
