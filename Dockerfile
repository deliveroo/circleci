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

ADD ci /usr/bin/ci
ADD wait-for-it.sh /usr/bin/wfi
