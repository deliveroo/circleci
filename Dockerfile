FROM node:9.1.0-alpine

ENV AWSCLI_VERSION=1.11.129
ENV DOCKER_VERSION=17.07.0-r0
ENV COMPOSE_VERSION=1.17.0

ARG EDGE_REPO=http://dl-cdn.alpinelinux.org/alpine/edge/community

RUN echo $EDGE_REPO >> /etc/apk/repositories \
    && apk add --no-cache bash \
                          curl \
                          docker=${DOCKER_VERSION} \
                          git \
                          gzip \
                          openssh-client \
                          py-pip \
                          tar \
    && pip install --upgrade pip \
    && pip install awscli==${AWSCLI_VERSION} docker-compose==${COMPOSE_VERSION}

# Install Heroku CLI.
ENV HEROKU_VERSION=6.14.36
RUN npm install -g heroku-cli@$HEROKU_VERSION

ADD scripts/ci.sh /usr/bin/ci
ADD scripts/clean_up_reusable_docker.sh /usr/bin/clean_up_reusable_docker
ADD scripts/ensure_head.sh /usr/bin/ensure_head
ADD scripts/push_image_to_ecr.sh /usr/bin/push_image_to_ecr
ADD scripts/print_env.py /usr/bin/print_env
ADD scripts/push_to_heroku.sh /usr/bin/push_to_heroku
ADD scripts/wait-for-it.sh /usr/bin/wfi
