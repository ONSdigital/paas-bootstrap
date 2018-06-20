#!/bin/bash

# Puts BOSH out of its misery

set -euo pipefail

: $ENVIRONMENT
if [ -z "${AWS_PROFILE:-}" ]; then
  : $AWS_ACCESS_KEY_ID
  : $AWS_SECRET_ACCESS_KEY
fi


VARS=/var/tmp/tmp$$
trap 'rm -rf $VARS' EXIT
mkdir -p "$VARS"

aws s3 cp "s3://${ENVIRONMENT}-states/bosh/bosh.yml" "${VARS}/bosh.yml"
aws s3 cp "s3://${ENVIRONMENT}-states/bosh/bosh-state.json" "${VARS}/bosh-state.json"

bin/bosh_credentials.sh -e "$ENVIRONMENT" bosh delete-env \
  --state "${VARS}/bosh-state.json" \
 "$VARS/bosh.yml"

aws s3 rm "s3://${ENVIRONMENT}-states/bosh/bosh.yml" || true
aws s3 rm "s3://${ENVIRONMENT}-states/bosh/bosh-variables.yml" || true
aws s3 rm "s3://${ENVIRONMENT}-states/bosh/bosh-state.json" || true
