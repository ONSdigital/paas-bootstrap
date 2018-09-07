#!/bin/bash

set -euo pipefail

while getopts e: option; do
  case $option in
    e) export ENVIRONMENT="$OPTARG";;
  esac
done

: $ENVIRONMENT

creds() {
  SVC=$1
  KEY=$2
  echo "$SVC"
  echo "  URL: https://$(bin/outputs.sh base | jq -r .${KEY}_fqdn)"
  echo "  Pass: $(bin/secret.sh -e $ENVIRONMENT -d prometheus -k ${KEY}_password)"
  echo
}

creds Grafana grafana
creds Prometheus prometheus
creds Alertmanager alertmanager