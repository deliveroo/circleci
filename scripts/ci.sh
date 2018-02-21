#!/usr/bin/env bash

set -ex

case "$1" in

  "tag" )
    docker tag project_app:latest "${CIRCLE_PROJECT_REPONAME}:${CIRCLE_SHA1}"
    ;;

  * )
    docker-compose -f docker-compose.ci.yml "$@"
    ;;
esac
