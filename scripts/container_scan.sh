#!/bin/bash

if [ -z "${SNYK_TOKEN}" ]; then
  echo "Please set SNYK_TOKEN variable in CircleCI project settings"
  exit 1
fi

if [ -z "${GITHUB_SNYK_TOKEN}" ]; then
  echo "Please set GITHUB_SNYK_TOKEN variable in CircleCI project settings"
  exit 1
fi

TAG_NAME=${CONTAINER_TAG:="latest"}
export SEVERITY_THRESHOLD=${SNYK_SEVERITY_THRESHOLD:="high"}

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

## set tag
SNYK_FNAME=snyk.json

## lets retag the image
docker image tag ${CIRCLE_PROJECT_REPONAME}:${CIRCLE_SHA1} ${CIRCLE_PROJECT_REPONAME}:${TAG_NAME}

## test 
snyk test --severity-threshold=${SEVERITY_THRESHOLD} --docker ${CIRCLE_PROJECT_REPONAME}:${TAG_NAME} --file=${PROJECT_PATH}/Dockerfile --json > "${PROJECT_PATH}/${SNYK_FNAME}"

echo "[*] Finished snyk test. Moving onto monitor"

## monitor
snyk monitor --docker ${CIRCLE_PROJECT_REPONAME}:${TAG_NAME} --file="${PROJECT_PATH}/Dockerfile"

echo "[*] Finished snyk monitoring. Checking if we need to send results to GitHub"

## parse results and check if we should comment back to GitHub
if [[ -z "${CIRCLE_PULL_REQUEST}" ]]; then
  echo "Not a pull request. Exiting"
else
  parse_and_post_comment "${PROJECT_PATH}/${SNYK_FNAME}"
fi
