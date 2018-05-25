#!/bin/bash

set -euo pipefail

INTERNAL_IP=$(bosh int --path /instance_groups/name=bosh/networks/name=default/static_ips/0 bosh-manifest-s3/bosh.yml)

wget -qO - -t 1 -T 5 "https://${INTERNAL_IP}:25555/info" \
  --ca-certificate=<(bosh int --path /cloud_provider/cert/ca bosh-manifest-s3/bosh.yml) | jq .