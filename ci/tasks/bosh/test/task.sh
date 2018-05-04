#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

aws s3 cp s3://"$ENVIRONMENT"-states/bosh/creds.yml "$ENVIRONMENT"_creds.yml

BOSH_IP=$(bosh int --path /bosh_ip "$ENVIRONMENT"_creds.yml)

curl https://${BOSH_IP}:25555
