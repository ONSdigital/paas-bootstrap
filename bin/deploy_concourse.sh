#!/bin/bash

# Creates a wee Concourse

set -euo pipefail


: $AWS_ACCESS_KEY_ID
: $AWS_SECRET_ACCESS_KEY
: $CONCOURSE_TERRAFORM_STATE_FILE
: $CONCOURSE_STATE_FILE
: $CONCOURSE_CREDS_FILE
: $PRIVATE_KEY_FILE

# Convert the terraform outputs to YAML
_vars_file=tmp.$$.yml
trap 'rm -f $_vars_file' EXIT
terraform output -state="$CONCOURSE_TERRAFORM_STATE_FILE" -json | jq 'with_entries(.value = .value.value)' | yq r - >"$_vars_file"

SUBMODULE=concourse-bosh-deployment

bosh create-env "$SUBMODULE"/lite/concourse.yml \
  -o "$SUBMODULE"/lite/infrastructures/aws.yml \
  -o operations/concourse/public-network.yml \
  -o operations/concourse/basic-auth.yml \
  -o operations/concourse/elb.yml \
  -l "$SUBMODULE"/versions.yml \
  -l "$_vars_file" \
  -v access_key_id="$AWS_ACCESS_KEY_ID" \
  -v secret_access_key="$AWS_SECRET_ACCESS_KEY" \
  --var-file private_key="$PRIVATE_KEY_FILE" \
  --vars-store "$CONCOURSE_CREDS_FILE" \
  --state "$CONCOURSE_STATE_FILE"
