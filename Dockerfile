FROM docker:17.03.2-ce

ENV AWSCLI_VERSION=1.11.129
RUN apk add --no-cache bash \
                       curl \
                       git \
                       gzip \
                       openssh-client \
                       py-pip \
                       tar \
    && pip install --upgrade pip \
    && pip install awscli==${AWSCLI_VERSION} boto3 docker-compose requests

# Install Terraform binary.
ENV TERRAFORM_VERSION=0.10.0
ARG HOSTPATH=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}
ARG FILENAME=terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN set -ex \
    && cd /usr/local/bin \
    && curl ${HOSTPATH}/${FILENAME} -o $FILENAME \
    && unzip $FILENAME \
    && rm $FILENAME

ADD scripts/ci /usr/bin/ci
ADD scripts/ecr-cleanup.py /usr/bin/ecr-cleanup
ADD scripts/wait-for-it.sh /usr/bin/wfi
