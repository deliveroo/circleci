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

# Install Terraform binary.
ENV TERRAFORM_VERSION=0.10.0
ARG HOSTPATH=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}
ARG FILENAME=terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN set -ex \
    && cd /usr/local/bin \
    && curl ${HOSTPATH}/${FILENAME} -o $FILENAME \
    && unzip $FILENAME \
    && rm $FILENAME

# Install Heroku CLI.
ENV HEROKU_VERSION=6.13.10
RUN npm install -g heroku-cli@$HEROKU_VERSION

ADD scripts/ci.sh /usr/bin/ci
ADD scripts/ensure_head.sh /usr/bin/ensure_head
ADD scripts/push_image_to_ecr.sh /usr/bin/push_image_to_ecr
ADD scripts/push_sha_to_terraform.sh /usr/bin/push_sha_to_terraform
ADD scripts/push_to_heroku.sh /usr/bin/push_to_heroku
ADD scripts/wait-for-it.sh /usr/bin/wfi
