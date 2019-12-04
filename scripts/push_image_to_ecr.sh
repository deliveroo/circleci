#!/usr/bin/env bash

## Script to push local docker images to ECR
#
# Variables:-
#
# * $AWS_ACCESS_KEY_ID - AWS access key (required)
# * $AWS_SECRET_ACCESS_KEY - AWS secret key (required)
# * $IMAGE_NAME or $CIRCLE_PROJECT_REPONAME - local image name (required)
# * $AWS_ECR_REPO_URL - the ECR repo URL (required)
# * $AWS_ECR_REPO_REGION or $AWS_REGION - the AWS region to use (required)
# * CIRCLE_SHA1 - the CircleCI SHA1 of the current commit, used as the first tag
#
# Extra variables:-
# * $MAX_RETRY_COUNT_FOR_PUSHING_DOCKER_IMAGE - how many times to push before
#     giving up (optional, default: 3)
# * $DEBUG - define to allow debug logs
# * $FORCE_COLOUR - define to force coloured output
#
# Parameters:-
# * Zero or more custom tags
#
# Notes:-
# Script will take image name from $IMAGE_NAME if defined, or $CIRCLE_PROJECT_REPONAME
# if not. One or other must be set.
# Script will take region from $AWS_ECR_REPO_REGION if set, or $AWS_REGION if not. One
# or other must be set.
# The set of tags to push to always includes $CIRCLE_SHA1. Any custom tags passed on the
# command line are appended to the set.

my_dirname=$(dirname "$0")
my_basename=$(basename "$0")

push_retry_limit=${MAX_RETRY_COUNT_FOR_PUSHING_DOCKER_IMAGE:-3}

# shellcheck source=common
source "$my_dirname/common"

error_usage() {
    echo -e "$ERR_HDR$*"
    cat >&2 <<!

Usage: $my_basename [<tag>] [<tag> ... ]
!
    exit 1
}

tag_and_push() {
    src=$1
    dst=$2
    info "Tagging docker image..."
    docker tag "$src" "$dst" || error "Failed to tag $src as $dst"
    info "Pushing $dst to ECR..."
    push_with_retry "$dst" || error "Failed to push $dst"
    info "Successfully pushed $dst to ECR"
}

push_with_retry() {
    count=0
    dst=$1
    until docker push "$dst"; do
        ((count++))
        if ((count == push_retry_limit)); then
            warn "Too many retries ... giving up"
            return 1
        else
            warn "Retrying push (attempt $((count+1)))"
            sleep "$((count*5))"
        fi
    done
}

if [[ -z $AWS_ACCESS_KEY_ID ]]; then
  error "Please set AWS_ACCESS_KEY_ID variable in CircleCI project settings"
fi

if [[ -z $AWS_SECRET_ACCESS_KEY ]]; then
  error "Please set AWS_SECRET_ACCESS_KEY variable in CircleCI project settings"
fi

if [[ $IMAGE_NAME ]]; then
    local_image=$IMAGE_NAME
    info "Local image name from \$IMAGE_NAME: $local_image"
elif [[ $CIRCLE_PROJECT_REPONAME ]]; then
    local_image=$CIRCLE_PROJECT_REPONAME
    info "Local image name from \$CIRCLE_PROJECT_REPONAME: $local_image"
else
    error "You must set either \$IMAGE_NAME or \$CIRCLE_PROJECT_REPONAME"
fi

if [[ $AWS_ECR_REPO_URL ]]; then
    repo_url=$AWS_ECR_REPO_URL
    info "Repo URL from \$AWS_ECR_REPO_URL: $repo_url"
else
    error "You must set \$AWS_ECR_REPO_URL to the remote repo URL"
fi

if [[ $AWS_ECR_REPO_REGION ]]; then
    region=$AWS_ECR_REPO_REGION
    info "Region from \$AWS_ECR_REPO_REGION: $region"
elif [[ $AWS_REGION ]]; then
    region=$AWS_REGION
    info "Region from \$AWS_REGION: $region"
else
    error "You must set either \$AWS_ECR_REPO_REGION or \$AWS_REGION"
fi

if [[ -z $CIRCLE_SHA1 ]]; then
    error "Expecting \$CIRCLE_SHA1 to be set"
fi

tags=("$CIRCLE_SHA1" "$@")

printf '%s\n' "${tags[@]}" | grep -q '^--' && error_usage "It looks like you're passing flags instead of tags"

info "Fetching ECR login command"
if ! command=$(aws ecr get-login --no-include-email --region "$region"); then
    error "Problem executing 'aws ecr get-login command"
fi

info "Logging in to repo"
$command || error "Problem logging in to repo"

for tag in "${tags[@]}"; do
    tag_and_push "$local_image:$CIRCLE_SHA1" "$repo_url:$tag"
done
