#!/bin/bash

set -euo pipefail

cp prometheus-vars-s3/prometheus-variables.yml prometheus-manifests/prometheus-variables.yml
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "cf-tfstate-s3/${ENVIRONMENT}.tfstate" > cf-vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "bosh-tfstate-s3/${ENVIRONMENT}.tfstate" > bosh-vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < vpc-tfstate-s3/tfstate.json > vpc-vars.json

PROMETHEUS_MANIFESTS=prometheus-deployment-git/manifests
SYSTEM_DOMAIN="system.${DOMAIN}"

bosh interpolate --path /default_ca/ca bosh-vars-s3/bosh-variables.yml > bosh_ca_cert.pem

bosh -d prometheus interpolate "$PROMETHEUS_MANIFESTS"/prometheus.yml \
  --vars-store prometheus-manifests/prometheus-variables.yml \
  -o "$PROMETHEUS_MANIFESTS"/operators/monitor-bosh.yml \
  -v bosh_url="$(jq -r .bosh_director_fqdn < bosh-vars.json)" \
  -v bosh_username="admin" \
  -v bosh_password="$(bosh interpolate --path /admin_password bosh-vars-s3/bosh-variables.yml)" \
  --var-file bosh_ca_cert=bosh_ca_cert.pem \
  -v metrics_environment="$ENVIRONMENT" \
  -v metron_deployment_name="$SYSTEM_DOMAIN" \
  -v system_domain="$SYSTEM_DOMAIN" \
  -v uaa_clients_cf_exporter_secret="$(bosh interpolate --path /uaa_clients_cf_exporter_secret cf-vars-s3/cf-variables.yml)" \
  -v uaa_clients_firehose_exporter_secret="$(bosh interpolate --path /uaa_clients_firehose_exporter_secret cf-vars-s3/cf-variables.yml)" \
  -v traffic_controller_external_port="$(jq -r .cf_traffic_controller_port < cf-vars.json)" \
  -v skip_ssl_verify=false \
  > prometheus-manifests/prometheus.yml

