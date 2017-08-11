# Deliveroo CircleCI helper image

The purpose of this image is to make interacting with CircleCI 2.0 easier, and provide a few opinionated suggestions on how to best run CI pipelines.

In order to use this image, please use it as the starter image in your CircleCI config file (`.circleci/config.yml`):

```yaml
docker:
  - image: deliveroo/circleci:$VERSION
```

...where `VERSION` equals the version you want to use. Hint: its value is located in the `VERSION` file in this repo.

The image comes with a few standard tools, like `docker`, `docker-compose`, `heroku` CLI, `terraform` CLI, `aws` CLI, and `python` with `pip`. It also has some custom helpers - please see below for details.

## Custom helper: `ci`

`ci` is just an alias for a more complicated `docker-compose -f docker-compose.ci.yml`. It is opinionated in that it assumes that the Docker composition for your CI pipeline (if you're using one, of course), is stored in a file called `docker-compose.ci.yml`. This way your can reserve your vanilla Docker Compose file (`docker-compose.yml`) just for development purposes.

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
    command: ci run --rm wait db:5432

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

## Custom helper: `push_to_heroku`

`push_to_heroku` wraps around some of the logic necessary to run a `git push` deployment to Heroku from the CircleCI pipeline. This is meant to replace a GitHub-Heroku integration to provide better visibility into the deployment process. In order to use it, you will need to set two environment variables in the CircleCI project dashboard: `$HEROKU_LOGIN` and `$HEROKU_API_KEY`. The first one is the login (email) of the user on behalf of whom we're running the push. The latter is the long-lived API key for that user. Note: when generating these credentials please use service accounts.

In order to use `push_to_heroku` in your CircleCI pipeline, add a step like this - ideally you'd want to scope it to a staging or production branch of your repo:

```yaml
- run:
  name: Push to staging
  command: push_to_heroku $staging_app_name
```

## Future work

Over time we may end up adding utilities here to help us work with various other parts of our infrastructure.
