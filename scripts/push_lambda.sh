#!/usr/bin/env bash

set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <lambda-function-name>"
  exit 1
fi

FUNCTION_NAME=$1

`print_env ${TARGET}`

set -ex

# Copy source code to S3.
ARTEFACT=workspace/${FUNCTION_NAME}-${CIRCLE_SHA1}.zip
DESTINATION=s3://${AWS_S3_BUCKET_NAME}/${AWS_S3_OBJECT_KEY}
aws s3 cp ${ARTEFACT} ${DESTINATION}

# Atomically update the function source, and use the new version.
FUNCTION_VERSION=$(aws --region ${AWS_REGION} lambda update-function-code \
                       --function-name ${FUNCTION_NAME} \
                       --publish \
                       --s3-bucket ${AWS_S3_BUCKET_NAME} \
                       --s3-key ${AWS_S3_OBJECT_KEY} | jq -r '.Version')

# Create an alias for the newly uploaded version.
aws --region ${AWS_REGION} lambda create-alias \
    --function-name ${FUNCTION_NAME} \
    --function-version ${FUNCTION_VERSION} \
    --name ${CIRCLE_SHA1}
