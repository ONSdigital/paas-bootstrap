#!/bin/bash

# Creates a wee Concourse

set -euo pipefail

: $ENVIRONMENT
# BOSH create-env still requires the access credentials, rather than AWS_PROFILE
if [ -n "${AWS_PROFILE:-}" ]; then
  export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
  export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
fi
: $AWS_ACCESS_KEY_ID
: $AWS_SECRET_ACCESS_KEY
: $CONCOURSE_TERRAFORM_STATE_FILE
: $CONCOURSE_STATE_FILE
: $CONCOURSE_CREDS_FILE
: $PRIVATE_KEY_FILE

git submodule update --init

# Convert the terraform outputs to YAML
_vars_file=tmp.$$.yml
trap 'rm -f $_vars_file' EXIT
terraform output -state="$CONCOURSE_TERRAFORM_STATE_FILE" -json | jq 'with_entries(.value = .value.value)' | yq r - >"$_vars_file"

SUBMODULE=concourse-bosh-deployment

aws s3 cp "s3://${ENVIRONMENT}-states/concourse/creds.yml" "${CONCOURSE_CREDS_FILE}" ||
  echo "Remote concourse creds do not exist, assuming they need to be generated"

aws s3 cp "s3://${ENVIRONMENT}-states/concourse/state.json" "${CONCOURSE_STATE_FILE}" ||
  echo "Remote concourse state does not exist, assuming this is a new deployment"

bosh create-env "$SUBMODULE"/lite/concourse.yml \
  -o "$SUBMODULE"/lite/infrastructures/aws.yml \
  -o operations/concourse/public-network.yml \
  -o operations/concourse/basic-auth.yml \
  -o operations/concourse/alb.yml \
  -o operations/concourse/fqdn.yml \
  -o operations/concourse/iam_instance_profile.yml \
  -o operations/concourse/ephemeral_disk.yml \
  -o operations/concourse/tags.yml \
  -l "$SUBMODULE"/versions.yml \
  -l "$_vars_file" \
  -v environment="$ENVIRONMENT" \
  -v access_key_id="$AWS_ACCESS_KEY_ID" \
  -v secret_access_key="$AWS_SECRET_ACCESS_KEY" \
  --var-file private_key="$PRIVATE_KEY_FILE" \
  --vars-store "$CONCOURSE_CREDS_FILE" \
  --state "$CONCOURSE_STATE_FILE"

aws s3 cp "${CONCOURSE_CREDS_FILE}" "s3://${ENVIRONMENT}-states/concourse/creds.yml" --acl=private
aws s3 cp "${CONCOURSE_STATE_FILE}" "s3://${ENVIRONMENT}-states/concourse/state.json" --acl=private


