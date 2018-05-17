# Deliveroo CircleCI helper image

The purpose of this image is to make interacting with CircleCI 2.0 easier, and provide a few opinionated suggestions on how to best run CI pipelines.

In order to use this image, please use it as the starter image in your CircleCI config file (`.circleci/config.yml`):

```yaml
docker:
  - image: deliveroo/circleci:$VERSION
```

...where `VERSION` equals the version you want to use. Hint: its value is located in the `VERSION` file in this repo.

The image comes with a few standard tools, like `docker`, `docker-compose`, `heroku` CLI, `aws` CLI, and `python` with `pip`. It also has some custom helpers - please see below for details.

## Custom helper: `ci`

`ci` is just an alias for a more complicated `docker-compose -f docker-compose.ci.yml`. It is opinionated in that it assumes that the Docker composition for your CI pipeline (if you're using one, of course), is stored in a file called `docker-compose.ci.yml`. This way your can reserve your vanilla Docker Compose file (`docker-compose.yml`) just for development purposes.

If you built the Docker Image with `ci build`, `ci tag` can be used to tag the image in a suitable format for the `push_image_to_ecr` script.

```yaml
# In .circleci/config.yml, add this as one of the steps to build and tag the Docker image
- run:
    name: Build and Tag the CI Image
    command: |
      ci build
      ci tag
```

## Custom helper: `wfi`

The other helper you can find useful is `wfi`. It's just a `wait-for-it.sh` script with a shorter, more catchy name. Unlike `ci`, which is supposed to be run directly, `wfi` only makes sense to be run from a composition. As an example, let's see a simple Rails test composition:

```yaml
version: '3'

services:
  db:
    image: postgres:9.6.3

  app:
    build:
      context: .
      dockerfile: Dockerfile.ci
    links:
      - db

  wait:
    image: deliveroo/circleci:$VERSION
    links:
      - db
```

Now in your test steps you can use `wfi` to wait for the DB to come up before you set it up from a Rails schema:

```yaml
- run:
    name: Wait for the DB to start
    command: ci run --rm wait wfi db:5432

- run:
    name: Set up the DB
    command: ci run --rm app bin/rails db:create db:migrate
```

## Custom helper: `ensure_head`

`ensure_head` will check whether the CI run was triggered by the current `HEAD` of the branch it ran from. Running from outdated commits may be wasteful at best, and dangerous at worst. In case of continuous deployment you can imagine re-running an old CI run sneakily changing the code in production to an older version.

In order to use `ensure_head`, just add it as a step to your CircleCI config file:

```yaml
- run:
    name: Ensure HEAD
    command: ensure_head
```

## Custom helper: `push_lambda`

`push_lambda` is a helper to push an externally generated zip file to S3 and use it to update the source code of a Lambda function. It assumes that `AWS_S3_BUCKET_NAME`, `AWS_S3_OBJECT_KEY` and `AWS_REGION` environment variables are set - either directly or indirectly (see `print_env`),

In order to use `push_lambda`, just add it as a step to your CircleCI config file:

```yaml
- run:
    name: Update Lambda function
    command: push_lambda $function_name
```

## Custom helper: `push_to_heroku`

`push_to_heroku` wraps around some of the logic necessary to run a `git push` deployment to Heroku from the CircleCI pipeline. This is meant to replace a GitHub-Heroku integration to provide better visibility into the deployment process. In order to use it, you will need to set two environment variables in the CircleCI project dashboard: `$HEROKU_LOGIN` and `$HEROKU_API_KEY`. The first one is the login (email) of the user on behalf of whom we're running the push. The latter is the long-lived API key for that user. Note: when generating these credentials please use service accounts.

In order to use `push_to_heroku` in your CircleCI pipeline, add a step like this - ideally you'd want to scope it to a staging or production branch of your repo:

```yaml
- run:
    name: Push to staging
    command: push_to_heroku $staging_app_name
```

## Custom helper: `push_image_to_ecr`

`push_image_to_ecr` wraps around the logic required to use your AWS environment
variables to log in to an ECR repository and tag and push your local image there. In order to use it, you will need to set two environment variables in the CircleCI project dashboard: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` - these are used by the AWS CLI that lets us retrieve Docker credentials.

In order to use `push_to_heroku` in your CircleCI pipeline, add a step like this - ideally you'd want to scope it to a staging or production branch of your repo. Please mind the fact that options can't use `=` between key and value - it's not supported it in the Bash script.

```yaml
- run:
    name: Push image to ECR
    command: |
      push_image_to_ecr \
        --image-name IMAGE_NAME \
        --ecr-repo ECR_REPO \
        --aws-region AWS_REGION
```

## Custom helper: `clean_up_reusable_docker`

`clean_up_reusable_docker` wraps around the logic required to remove dangling containers, and old images from the remote Docker host used by CircleCI. It's a way to still be able to use cache, while not wasting all that space:

```yaml
- run:
    name: Clean up reusable Docker
    command: clean_up_reusable_docker
```

## Custom helper: `print_env`

`print_env` is a Python script which takes prefix and replaces prefixed environment variables with their non-prefixed versions. You're always meant to exec it in-place for the changes to be made to the current shell.:

```yaml
- run:
    name: Push to staging
    command: |
      `print_env staging`
      push_to_heroku $staging_app_name
```

## Custom helper: `set_aws_credentials`

`set_aws_credentials` is a Python script which takes a `namespace` as an argument and sets the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables with the values that come from their prefixed versions with `{namespace}_`. You're always meant to exec it in-place for the changes to be made to the current shell.:

```yaml
- run:
    name: Push to staging
    command: |
      `set_aws_credentials staging`
      push_image_to_ecr \
        --image-name IMAGE_NAME \
        --ecr-repo sandbox_my_app_AWS_ECR_REPO_URL \
        --aws-region AWS_REGION
```

## Future work

Over time we may end up adding utilities here to help us work with various other parts of our infrastructure.
