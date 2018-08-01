#!/bin/bash

set -euo pipefail

: $USERNAME
: $PASSWORD
: $HOST_GRAFANA

apikey_name=temp$$key

# create API key
apikey=$(curl -s -X POST -H "Content-Type: application/json" -d '{"name": "'${apikey_name}'", "role": "Admin"}'\
 https://${USERNAME}:${PASSWORD}@${HOST_GRAFANA}/api/auth/keys | jq -r '.key')

# upload dashboard
curl -s -X POST https://${HOST_GRAFANA}/api/dashboards/db \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${apikey}" \
-d @paas-bootstrap-git/templates/bosh_cpu.json

# get existing API key
apikey_id=$(curl -s -X GET \
  https://${HOST_GRAFANA}/api/auth/keys \
  -H "Authorization: Bearer ${apikey}" \
  -H 'Cache-Control: no-cache' | jq '.[] | select(.name=="'${apikey_name}'") | .id ')

# delete API key
curl -s -X DELETE \
  https://${HOST_GRAFANA}/api/auth/keys/${apikey_id} \
  -H "Authorization: Bearer ${apikey}" \
  -H 'Cache-Control: no-cache' -o /dev/null