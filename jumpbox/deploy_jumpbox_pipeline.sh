#!/bin/bash

set -euo pipefail
set -x
: $ENVIRONMENT

bin/login_fly.sh

# Grab pre-requisite files from S3
aws s3 cp "s3://${ENVIRONMENT}-states/concourse/tfstate.json" "${CONCOURSE_TERRAFORM_STATE_FILE}"
aws s3 cp "s3://${ENVIRONMENT}-states/concourse/creds.yml" "${CONCOURSE_CREDS_FILE}"

REGION=$(terraform output -state=${ENVIRONMENT}_concourse.tfstate.json region)
S3_KMS_KEY_ID=$(terraform output -state=${ENVIRONMENT}_concourse.tfstate.json s3_kms_key_id)

fly -t "$ENVIRONMENT" set-pipeline \
    -v environment="$ENVIRONMENT" \
    -v region="$REGION" \
    -v s3_kms_key_id="$S3_KMS_KEY_ID" \
    -c jumpbox/pipeline.yml -p jumpbox -n
fly -t "$ENVIRONMENT" unpause-pipeline -p jumpbox 

