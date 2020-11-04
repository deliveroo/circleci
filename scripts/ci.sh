#!/usr/bin/env bash

set -ex

case "$1" in

  "tag" )
    docker tag "${CIRCLE_PROJECT_REPONAME}_app":latest "${CIRCLE_PROJECT_REPONAME}:${CIRCLE_SHA1}"
    ;;

  * )
    docker-compose -f docker-compose.ci.yml -p "${CIRCLE_PROJECT_REPONAME}" $@"
    ;;
esac
