#!/bin/bash

# Retrieves the concourse admin credentails

set -euo pipefail

: $ENVIRONMENT
if [ -z "${AWS_PROFILE:-}" ]; then
  echo "Profile not set"
  exit 1
fi

_tmp_creds=tmp$$.tmp_creds.yml
trap 'rm -f $_tmp_creds' EXIT

aws s3 cp "s3://ons-paas-${ENVIRONMENT}-states/concourse/creds.yml" "${_tmp_creds}"
bosh int --path /admin_password $_tmp_creds
