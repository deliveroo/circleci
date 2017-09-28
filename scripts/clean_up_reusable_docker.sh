#!/usr/bin/env bash

set -e

docker system prune -f

docker images -f "dangling=true" --format "{{.ID}} {{.CreatedSince}}" \
  | grep "weeks ago" | cut -f 1 -d " " \
  | xargs --no-run-if-empty docker rmi
