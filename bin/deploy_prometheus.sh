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

BOSH="bin/bosh_credentials.sh -e $ENVIRONMENT bosh"

SYSTEM_DOMAIN="system.$(output base .domain)"
METRON_DEPLOYMENT_NAME=cf

export BOSH_CA_CERT=/var/tmp/bosh_ca.$$.pem
bosh int --path /default_ca/ca "data/$ENVIRONMENT-bosh-variables.yml" >$BOSH_CA_CERT

cleanup() {
  rm -f $BOSH_CA_CERT
}
trap cleanup EXIT

$BOSH -d prometheus deploy -n prometheus-boshrelease/manifests/prometheus.yml \
  -o prometheus-boshrelease/manifests/operators/monitor-bosh.yml \
  -o prometheus-boshrelease/manifests/operators/monitor-cf.yml \
  -o ./operations/prometheus/networks.yml \
  -v bosh_url="$(output base .bosh_director_fqdn)" \
  -v bosh_username="admin" \
  -v bosh_password="$(bosh interpolate --path /admin_password data/$ENVIRONMENT-bosh-variables.yml)" \
  --var-file bosh_ca_cert=$BOSH_CA_CERT \
  -v metrics_environment="$ENVIRONMENT" \
  -v metron_deployment_name="$METRON_DEPLOYMENT_NAME" \
  -v system_domain="$SYSTEM_DOMAIN" \
  -v uaa_clients_cf_exporter_secret="$(secret uaa_clients_cf_exporter_secret)" \
  -v uaa_clients_firehose_exporter_secret="$(secret uaa_clients_firehose_exporter_secret)" \
  -v traffic_controller_external_port="$(output base .cf_traffic_controller_port)" \
  -v skip_ssl_verify=false
