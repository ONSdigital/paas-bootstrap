#!/bin/bash

set -euo pipefail

: $ENVIRONMENT
: $SNAPSHOT_NAME
: $TEMPLATE

# vars
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "prometheus-tfstate-s3/${ENVIRONMENT}.tfstate" > prometheus-vars.json
HOST="$(jq -r .grafana_fqdn < prometheus-vars.json)"
USER=$(bosh int prometheus-manifest-s3/prometheus.yml --path /instance_groups/name=grafana/jobs/name=grafana/properties/grafana/security/admin_user)
PASS=$(bosh int prometheus-manifest-s3/prometheus.yml --path /instance_groups/name=grafana/jobs/name=grafana/properties/grafana/security/admin_password)

paas-bootstrap-git/bin/create_grafana_snapshot.sh -h "$HOST" -u "$USER" -p "$PASS" -f "$TEMPLATE" -n "$SNAPSHOT_NAME"