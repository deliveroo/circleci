#!/usr/bin/env bash

set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 ATLAS_ENVIRONMENT"
  exit 1
fi

ATLAS_ENVIRONMENT=$1

if [ -z "$ATLAS_TOKEN" ]; then
  echo "Please set ATLAS_TOKEN variable in CircleCI project settings"
  exit 1
fi

api_endpoint="https://atlas.hashicorp.com/api/v1"
env_endpoint="${api_endpoint}/environments/${ATLAS_ENVIRONMENT}"

# Push the new sha variable.
curl ${env_endpoint}/variables \
     -X PUT \
     -H 'Content-Type: application/json' \
     -d "{\"variables\":{\"deploy_sha\":\"$CIRCLE_SHA1\"}}" \
     -H "X-Atlas-Token: $ATLAS_TOKEN"

# Trigger a new Terraform plan.
curl ${env_endpoint}/plan \
     -X POST \
     -d "" \
     -H "X-Atlas-Token: $ATLAS_TOKEN"
