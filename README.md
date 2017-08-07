# Deliveroo CircleCI helper image

The purpose of this image is to make interacting with CircleCI 2.0 easier, and provide a few opinionated suggestions on how to best run CI pipelines.

In order to use this image, please use it as the starter image in your CircleCI config file (`.circleci/config.yml`):

```yaml
docker:
  - image: deliveroo/circleci:$VERSION
```

...where `VERSION` equals the version you want to use. Hint: its value is located in the `VERSION` file in this repo.

The image comes with a few standard tools, like `docker`, `docker-compose` and `python` with `pip`. It also has two custom helpers: `ci` and `wfi`.

`ci` is just an alias for a more complicated `docker-compose -f docker-compose.ci.yml`. It is opinionated in that it assumes that the Docker composition for your CI pipeline (if you're using one, of course), is stored in a file called `docker-compose.ci.yml`. This way your can reserve your vanilla Docker Compose file (`docker-compose.yml`) just for development purposes.

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

Over time we may end up adding utilities here to help us work with various other parts of our infrastructure.
