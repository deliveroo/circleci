#!/usr/bin/env bash

set -e

docker system prune -f

docker images --no-trunc --format '{{.ID}} {{.CreatedSince}}' \
    | grep ' weeks' | awk '{ print $1 }' \
    | xargs --no-run-if-empty docker rmi
