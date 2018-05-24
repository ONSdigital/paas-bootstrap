#!/bin/bash

# Euthanise Jumbox

set -euo pipefail

: $ENVIRONMENT
: $AWS_ACCESS_KEY_ID
: $AWS_SECRET_ACCESS_KEY

VARS=/var/tmp/tmp$$
trap 'rm -rf $VARS' EXIT
mkdir -p "$VARS"

aws s3 cp "s3://${ENVIRONMENT}-states/jumpbox/jumpbox.yml" "${VARS}/jumpbox.yml"
aws s3 cp "s3://${ENVIRONMENT}-states/jumpbox/jumpbox-state.json" "${VARS}/jumpbox-state.json"

bosh delete-env \
  --state "${VARS}/jumpbox-state.json" \
 "$VARS/jumpbox.yml"

aws s3 rm "s3://${ENVIRONMENT}-states/jumpbox/jumpbox.yml" || true
aws s3 rm "s3://${ENVIRONMENT}-states/jumpbox/jumpbox-variables.yml" || true
aws s3 rm "s3://${ENVIRONMENT}-states/jumpbox/jumpbox-state.json" || true
