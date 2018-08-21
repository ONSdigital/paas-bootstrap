FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash jq netcat dnsutils curl \
    build-essential zlibc zlib1g-dev ruby ruby-dev openssl \
    libxslt-dev libxml2-dev libssl-dev libreadline7 libreadline-dev libyaml-dev \
    libsqlite3-dev sqlite3

RUN curl -Lo /usr/local/bin/bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-5.1.2-linux-amd64
RUN chmod +x /usr/local/bin/bosh