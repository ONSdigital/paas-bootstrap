#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

VARS=/var/tmp/tmp$$
mkdir -p "$VARS"
trap 'rm -rf "$VARS"' EXIT

service="grafana"
username="admin"
apikey_name=temp$$key

# get grafana hostname
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "prometheus-tfstate-s3/${ENVIRONMENT}.tfstate" > "$VARS/vars.json"
host_grafana="$(jq -r .${service}_fqdn < "$VARS/vars.json")"

# get grafana password
password=$(egrep "^${service}_password:" prometheus-vars-s3/prometheus-variables.yml | awk '{print $2}')

# create API key
apikey=$(curl -s -X POST -H "Content-Type: application/json" -d '{"name": "'${apikey_name}'", "role": "Admin"}'\
 https://${username}:${password}@${host_grafana}/api/auth/keys | jq -r '.key')

# upload dashboard
curl -s -X POST https://${host_grafana}/api/dashboards/db \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${apikey}" \
-d @paas-bootstrap-git/templates/bosh_cpu.json 

# get existing API key
apikey_id=$(curl -s -X GET \
  https://${host_grafana}/api/auth/keys \
  -H "Authorization: Bearer ${apikey}" \
  -H 'Cache-Control: no-cache' | jq '.[] | select(.name=="'${apikey_name}'") | .id ')

# delete API key
curl -s -X DELETE \
  https://${host_grafana}/api/auth/keys/${apikey_id} \
  -H "Authorization: Bearer ${apikey}" \
  -H 'Cache-Control: no-cache' -o /dev/null