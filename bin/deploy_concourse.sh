#!/bin/bash

# Creates a wee Concourse

set -eux

: $AWS_ACCESS_KEY
: $AWS_SECRET_KEY
: ${CONCOURSE_SETTINGS:=concourse.yml}
: ${TERRAFORM_STATE_FILE:=concourse.tfstate.json}
: ${STATE_FILE:=concourse.state.json}
: ${CREDS_FILE:=concourse.creds.yml}

# Convert the terraform outputs to YAML
VARS_FILE=tmp.$$.yml
trap 'rm -f $VARS_FILE' EXIT
terraform output -state="$TERRAFORM_STATE_FILE" -json | jq 'with_entries(.value = .value.value)' | yq r - >"$VARS_FILE"

SUBMODULE=concourse-bosh-deployment

bosh create-env "$SUBMODULE"/lite/concourse.yml \
  -o "$SUBMODULE"/lite/infrastructures/aws.yml \
  -o concourse-ops.yml \
  -l "$SUBMODULE"/versions.yml \
  -l "$CONCOURSE_SETTINGS" \
  -l "$VARS_FILE" \
  -v access_key_id="$AWS_ACCESS_KEY" \
  -v secret_access_key="$AWS_SECRET_KEY" \
  --vars-store "$CREDS_FILE" \
  --state "$STATE_FILE"
  
