#!/bin/bash

set -euo pipefail

INTERNAL_IP=$(bosh int --path /instance_groups/name=bosh/networks/name=private/static_ips/0 bosh-manifest-s3/bosh.yml)

curl https://${INTERNAL_IP}:25555
