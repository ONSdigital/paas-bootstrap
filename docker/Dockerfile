FROM ubuntu:16.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash jq netcat dnsutils curl postgresql-client mysql-client \
    build-essential zlibc zlib1g-dev ruby ruby-dev openssl \
    libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev \
    libsqlite3-dev sqlite3

RUN curl -Lo /usr/local/bin/bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-5.1.2-linux-amd64
RUN chmod +x /usr/local/bin/bosh

ENV BOSH_AWS_CPI_URL https://bosh.io/d/github.com/cloudfoundry-incubator/bosh-aws-cpi-release?v=69
ENV BOSH_AWS_CPI_CHECKSUM 8abe70219244896ea6f7208fc01f2eac56179170

COPY bosh_init_cache /tmp/bosh_init_cache/
RUN /tmp/bosh_init_cache/seed_bosh_init_cache.sh && \
    rm -rf /tmp/bosh_init_cache
