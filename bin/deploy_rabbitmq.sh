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

RABBITMQ_STEMCELL_VERSION=3586.40
BROKER_PLAN_UUID=22F0B28C-B886-4123-B01B-95E54D3DE6DA
BROKER_UUID=568725FD-AD46-44CA-9853-621416E983A4

$BOSH -d rabbitmq deploy -n cf-rabbitmq-multitenant-broker-release/manifests/cf-rabbitmq-broker-template.yml \
  -o cf-rabbitmq-multitenant-broker-release/manifests/add-cf-rabbitmq.yml \
  -o ./operations/rabbitmq/release.yml \
  -v deployment-name=rabbitmq \
  -v stemcell-version="'$RABBITMQ_STEMCELL_VERSION'" \
  -v system-domain="$SYSTEM_DOMAIN" \
  -v apps_domain="$APPS_DOMAIN" \
  -v multitenant-rabbitmq-broker-username=broker \
  -v product-name=p-rabbitmq \
  -v rabbitmq-management-username=admin \
  -v rabbitmq-broker-hostname=rabbitmq-multitenant-broker \
  -v rabbitmq-broker-password=broker \
  -v rabbitmq-broker-plan-uuid="$BROKER_PLAN_UUID" \
  -v rabbitmq-broker-protocol=https \
  -v rabbitmq-broker-username=broker \
  -v rabbitmq-broker-uuid="$BROKER_UUID" \
  -v rabbitmq-management-hostname=pivotal-rabbitmq \
  -v cf-admin-username=admin \
  -v cf-admin-password=$(bin/cf_password.sh -e "$ENVIRONMENT") \
  -v cluster-partition-handling-strategy=autoheal \
  -v haproxy-instances=1 \
  -v haproxy-stats-username=admin \
  -v rabbitmq-hosts=[]

# NB: passwords are auto-generated in the deployment manifest - see operations/rabbitmq/release.yml

$BOSH -d rabbitmq run-errand broker-registrar

$BOSH -d rabbitmq run-errand smoke-tests

echo
echo
echo '*****************************************************'
echo 'The RabbitMQ service broker is installed and tested'
echo '*****************************************************'
