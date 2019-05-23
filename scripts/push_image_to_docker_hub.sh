#!/usr/bin/env bash

set +x -eo pipefail

# PURPOSE
# =======
# Pushes images to Docker Hub
#
# ENVIRONMENT
# ===========
# $DOCKER_USER - The username to use (required)
# $DOCKER_PASS - The password to use (required)
#
# USAGE
# =====
#
# push_image_to_docker_hub IMAGE [IMAGE...]

error() {
    echo "$*"
    exit 1
}

info() {
    echo "$*"
}

if [[ -z "$DOCKER_USER" ]]; then
    error "Please set DOCKER_USER variable in CircleCI project settings"
fi

if [[ -z "$DOCKER_PASS" ]]; then
    error "Please set DOCKER_PASS variable in CircleCI project settings"
fi

if [[ $# == 0 ]]; then
    error "Please pass at least one image name"
fi

# Log in to Docker repository
info "Logging in to Docker Hub"
docker login -u "${DOCKER_USER}" -p "${DOCKER_PASS}"

for image in "$@"; do
    info "Pushing the image '$image' to Docker Hub"
    docker push "$image"
done
