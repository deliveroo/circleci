FROM debian as extractor

# Instead of installing the full docker-ce distribution, which also pulls in
# the DKMS module and other stuff for running the server.
# Only install the docker client binary.
ENV DOCKER_VERSION=18.03.1-ce
RUN apt update && apt install -y curl \
    && curl https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz | \
    tar xzvf - -C /

FROM debian
COPY --from=extractor /docker/docker /usr/bin/docker

# AWS and docker-compose are python programs
ENV AWSCLI_VERSION=1.15.35
ENV COMPOSE_VERSION=1.21.2

RUN apt update \
    && apt install -y \
    bash \
    curl \
    git \
    jq \
    openssh-client \
    python \
    python-pip \
    zip \
    && python2 -m pip install --upgrade pip \
    && pip install awscli==${AWSCLI_VERSION} docker-compose==${COMPOSE_VERSION}

ADD scripts/ci.sh /usr/bin/ci
ADD scripts/clean_up_reusable_docker.sh /usr/bin/clean_up_reusable_docker
ADD scripts/ensure_head.sh /usr/bin/ensure_head
ADD scripts/push_image_to_ecr.sh /usr/bin/push_image_to_ecr
ADD scripts/pull_image_from_ecr.sh /usr/bin/pull_image_from_ecr
ADD scripts/push_image_to_docker_hub.sh /usr/bin/push_image_to_docker_hub
ADD scripts/print_env.py /usr/bin/print_env
ADD scripts/push_lambda.sh /usr/bin/push_lambda
ADD scripts/wait-for-it.sh /usr/bin/wfi
