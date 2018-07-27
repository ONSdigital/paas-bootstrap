#!/bin/bash

set -euo pipefail

if [ -z "${AWS_PROFILE:-}" ]; then
  echo "AWS_PROFILE not set."
  exit 1
fi

while getopts e: option; do
  case $option in
    e) ENVIRONMENT="$OPTARG";;
  esac
done

: $ENVIRONMENT

VARS=/var/tmp/tmp$$
mkdir -p "$VARS"
trap 'rm -rf "$VARS"' EXIT

aws s3 cp "s3://${ENVIRONMENT}-states/prometheus/prometheus-variables.yml" $VARS/prometheus-creds --quiet
aws s3 cp "s3://${ENVIRONMENT}-states/prometheus/${ENVIRONMENT}.tfstate" $VARS/state-tmp --quiet

grafana() {
    echo "Grafana"
    jq '.modules[0].outputs | with_entries(.value = .value.value)' < "$VARS/state-tmp" > "$VARS/vars.json"
    GRAFANA_FQDN=$(jq -r '.grafana_fqdn' < "$VARS/vars.json")
    echo "URL https://${GRAFANA_FQDN}"
    egrep '^grafana_password' $VARS/prometheus-creds
}

prometheus() {
    echo ''
    echo "Prometheus"
    jq '.modules[0].outputs | with_entries(.value = .value.value)' < "$VARS/state-tmp" > "$VARS/vars.json"
    PROMETHEUS_FQDN=$(jq -r '.prometheus_fqdn' < "$VARS/vars.json")
    echo "URL https://${PROMETHEUS_FQDN}"
    egrep '^prometheus_password' $VARS/prometheus-creds
}

grafana
prometheus