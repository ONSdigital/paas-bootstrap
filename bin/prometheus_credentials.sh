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
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "$VARS/state-tmp" > "$VARS/vars.json"

creds() {
  SVC=$1
  KEY=$2
  echo "$SVC"
  echo "URL https://$(jq -r .${KEY}_fqdn < "$VARS/vars.json")"
  egrep "^${KEY}_password:" $VARS/prometheus-creds
  echo
}

creds Grafana grafana
creds Prometheus prometheus
creds Alertmanager alertmanager