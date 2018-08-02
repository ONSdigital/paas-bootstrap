#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

apikey_name=temp$$key

# vars
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "prometheus-tfstate-s3/${ENVIRONMENT}.tfstate" > prometheus-vars.json
host_grafana="$(jq -r .grafana_fqdn < prometheus-vars.json)"
username=$(bosh int prometheus-manifests/prometheus.yml --path /instance_groups/name=grafana/jobs/name=grafana/properties/grafana/security/admin_user)
password=$(bosh int prometheus-manifests/prometheus.yml --path /instance_groups/name=grafana/jobs/name=grafana/properties/grafana/security/admin_password)

# create API key
apikey=$(curl -f --show-error -s -X POST -H "Content-Type: application/json" -d '{"name": "'${apikey_name}'", "role": "Admin"}'\
 https://${username}:${password}@${host_grafana}/api/auth/keys | jq -r '.key')

# upload dashboard
curl -f --show-error -s -X POST https://${host_grafana}/api/dashboards/db \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${apikey}" \
-d @paas-bootstrap-git/templates/bosh_cpu.json 

# get existing API key
apikey_id=$(curl -f --show-error -s -X GET \
  https://${host_grafana}/api/auth/keys \
  -H "Authorization: Bearer ${apikey}" \
  -H 'Cache-Control: no-cache' | jq '.[] | select(.name=="'${apikey_name}'") | .id ')

# delete API key
curl -f --show-error -s -X DELETE \
  https://${host_grafana}/api/auth/keys/${apikey_id} \
  -H "Authorization: Bearer ${apikey}" \
  -H 'Cache-Control: no-cache' -o /dev/null