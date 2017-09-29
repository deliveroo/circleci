FROM node:8.2.1-alpine

ENV AWSCLI_VERSION=1.11.129
ENV DOCKER_VERSION=17.05.0-r0
RUN apk add --no-cache bash \
                       curl \
                       docker=$DOCKER_VERSION \
                       git \
                       gzip \
                       openssh-client \
                       py-pip \
                       tar \
    && pip install --upgrade pip \
    && pip install awscli==${AWSCLI_VERSION} docker-compose

# Install Heroku CLI.
ENV HEROKU_VERSION=6.13.10
RUN npm install -g heroku-cli@$HEROKU_VERSION

ADD scripts/ci.sh /usr/bin/ci
ADD scripts/clean_up_reusable_docker.sh /usr/bin/clean_up_reusable_docker
ADD scripts/ensure_head.sh /usr/bin/ensure_head
ADD scripts/push_image_to_ecr.sh /usr/bin/push_image_to_ecr
ADD scripts/print_env.py /usr/bin/print_env
ADD scripts/push_to_heroku.sh /usr/bin/push_to_heroku
ADD scripts/wait-for-it.sh /usr/bin/wfi
