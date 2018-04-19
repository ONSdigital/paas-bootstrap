#!/bin/bash

# Creates a wee Concourse

set -euxo pipefail


: $AWS_ACCESS_KEY_ID
: $AWS_SECRET_ACCESS_KEY
: $CONCOURSE_SETTINGS
: $CONCOURSE_TERRAFORM_STATE_FILE
: $CONCOURSE_STATE_FILE
: $CONCOURSE_CREDS_FILE

# Convert the terraform outputs to YAML
local _vars_file=tmp.$$.yml
trap 'rm -f $_vars_file' EXIT
terraform output -state="$CONCOURSE_TERRAFORM_STATE_FILE" -json | jq 'with_entries(.value = .value.value)' | yq r - >"$_vars_file"

SUBMODULE=concourse-bosh-deployment

bosh create-env "$SUBMODULE"/lite/concourse.yml \
  -o "$SUBMODULE"/lite/infrastructures/aws.yml \
  -o concourse-ops.yml \
  -l "$SUBMODULE"/versions.yml \
  -l "$CONCOURSE_SETTINGS" \
  -l "$_vars_file" \
  -var aws_access_key_id="$AWS_ACCESS_KEY_ID" \
  -var aws_secret_access_key="$AWS_SECRET_ACCESS_KEY" \
  --vars-store "$CONCOURSE_CREDS_FILE" \
  --state "$CONCOURSE_STATE_FILE"
  
