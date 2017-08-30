#!/usr/bin/env bash

set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 APP_NAME"
  exit 1
fi

APP_NAME=$1

if [ -z "$HEROKU_LOGIN" ]; then
  echo "Please set HEROKU_LOGIN variable in CircleCI project settings"
  exit 1
fi

if [ -z "$HEROKU_API_KEY" ]; then
  echo "Please set HEROKU_API_KEY variable in CircleCI project settings"
  exit 1
fi

cat > ~/.netrc << EOF
machine git.heroku.com
  login $HEROKU_LOGIN
  password $HEROKU_API_KEY
EOF

heroku git:remote -a $APP_NAME -r $APP_NAME
git push $APP_NAME $CIRCLE_BRANCH:master
