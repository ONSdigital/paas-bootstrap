#!/bin/bash

# Creates a wee Concourse

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

CREDHUB_CA_CERT=/var/tmp/credhub_ca.$$.pem
bosh int --path /credhub_ca/ca "data/$ENVIRONMENT-bosh-variables.yml" >$CREDHUB_CA_CERT
CREDHUB_SERVER=https://$(output base .bosh_private_ip):8844
CREDHUB_CLIENT=credhub-admin
CREDHUB_SECRET=$(bosh int --path /credhub_admin_client_secret "data/$ENVIRONMENT-bosh-variables.yml")

cleanup() {
  rm -f $CREDHUB_CA_CERT
}
trap cleanup EXIT

$BOSH -d concourse deploy -n concourse-bosh-deployment/cluster/concourse.yml \
  -l concourse-bosh-deployment/versions.yml \
  -o concourse-bosh-deployment/cluster/operations/credhub.yml \
  -o ./operations/concourse/alb.yml \
  -o ./operations/concourse/tags.yml \
  -o ./operations/concourse/local-auth.yml \
  -o ./operations/concourse/skip-credhub-tls-validation.yml \
  -o ./operations/concourse/specific-dns.yml \
  -o ./operations/concourse/worker.yml \
  -v environment=$ENVIRONMENT \
  -v external_url=https://$(output base .concourse_fqdn) \
  -v network_name=concourse \
  -v web_vm_type=concourse \
  -v db_vm_type=concourse \
  -v db_persistent_disk_type=10GB \
  -v worker_vm_type=concourse \
  -v deployment_name=concourse \
  -v credhub_url="$CREDHUB_SERVER" \
  -v credhub_client_id="$CREDHUB_CLIENT" \
  -v credhub_client_secret="$CREDHUB_SECRET" \
  --var-file credhub_ca_cert="$CREDHUB_CA_CERT" \
  -v private_dns_nameserver="$(output base .vpc_dns_nameserver)"