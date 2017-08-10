#!/usr/bin/env bash

set -ex

REMOTE_SHA1=$(git ls-remote origin refs/heads/${CIRCLE_BRANCH} | cut -f 1)

if [ $REMOTE_SHA1 = $CIRCLE_SHA1 ];
then
  echo "Circle and remote Git SHA are both equal ${REMOTE_SHA1}"
  exit 0
fi

echo "Circle SHA (${CIRCLE_SHA1}) is not equal to remote SHA (${REMOTE_SHA1})"
echo "That means you're probably not running from the HEAD of ${CIRCLE_BRANCH}"
exit 1
