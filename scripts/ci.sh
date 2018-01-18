#!/usr/bin/env bash

set -ex

docker-compose -f docker-compose.ci.yml "$@"
