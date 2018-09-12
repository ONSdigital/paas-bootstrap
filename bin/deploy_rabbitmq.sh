#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

output() {
    FILE=$1
    QUERY=$2

    bin/outputs.sh $FILE | jq -r "$QUERY"
}

secret() {
  KEY=$1
  bin/secret.sh -e $ENVIRONMENT -d cf -k $KEY
}

bin/get_states.sh -e $ENVIRONMENT

BOSH="bin/bosh_credentials.sh -e $ENVIRONMENT bosh"

SYSTEM_DOMAIN="system.$(output base .domain)"
APPS_DOMAIN="apps.$(output base .domain)"

export BOSH_CA_CERT=$(bosh int --path /default_ca/ca "data/$ENVIRONMENT-bosh-variables.yml")

RABBITMQ_STEMCELL_VERSION=3586.36

$BOSH -d rabbitmq deploy -n cf-rabbitmq-multitenant-broker-release/manifests/cf-rabbitmq-broker-template.yml \
  -o cf-rabbitmq-multitenant-broker-release/manifests/add-cf-rabbitmq.yml \
  -o ./operations/rabbitmq/release.yml \
  -v deployment-name=rabbitmq \
  -v stemcell-version=3586.16 \
  -v system-domain="$SYSTEM_DOMAIN" \
  -v apps_domain="$APPS_DOMAIN" \
  -v multitenant-rabbitmq-broker-password=broker \
  -v multitenant-rabbitmq-broker-username=broker \
  -v product-name=p-rabbitmq \
  -v rabbitmq-management-password=admin \
  -v rabbitmq-management-username=admin \
  -v rabbitmq-broker-hostname=rabbitmq-multitenant-broker \
  -v rabbitmq-broker-password=broker \
  -v rabbitmq-broker-plan-uuid=22F0B28C-B886-4123-B01B-95E54D3DE6DA \
  -v rabbitmq-broker-protocol=http \
  -v rabbitmq-broker-username=broker \
  -v rabbitmq-broker-uuid=568725FD-AD46-44CA-9853-621416E983A4 \
  -v rabbitmq-management-hostname=pivotal-rabbitmq \
  -v cf-admin-password=admin \
  -v cf-admin-username=admin \
  -v cluster-partition-handling-strategy=autoheal \
  -v disk_alarm_threshold="{mem_relative,'0.4'}" \
  -v haproxy-instances=1 \
  -v haproxy-stats-password=admin \
  -v haproxy-stats-username=admin \
  -v rabbitmq-hosts=[]