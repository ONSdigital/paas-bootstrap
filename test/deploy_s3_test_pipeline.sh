#!/bin/bash

set -euo pipefail

: $ENVIRONMENT
: ${USERNAME:=admin}
: $CONCOURSE_TERRAFORM_STATE_FILE
: $CONCOURSE_CREDS_FILE

# Grab pre-requisite files from S3
aws s3 cp "s3://${ENVIRONMENT}-states/concourse/tfstate.json" "${CONCOURSE_TERRAFORM_STATE_FILE}"
aws s3 cp "s3://${ENVIRONMENT}-states/concourse/creds.yml" "${CONCOURSE_CREDS_FILE}"

FQDN=$(terraform output -state=${ENVIRONMENT}_concourse.tfstate.json concourse_fqdn)
PASSWORD=$(bosh int --path /admin_password ${ENVIRONMENT}_concourse.creds.yml)
REGION=$(terraform output -state=${ENVIRONMENT}_concourse.tfstate.json region)
S3_KMS_KEY_ID=$(terraform output -state=${ENVIRONMENT}_concourse.tfstate.json s3_kms_key_id)

fly login -t "$ENVIRONMENT" -u "$USERNAME" -p "$PASSWORD" -c "https://$FQDN"
fly -t "$ENVIRONMENT" set-pipeline \
    -v environment="$ENVIRONMENT" \
    -v region="$REGION" \
    -v s3_kms_key_id="$S3_KMS_KEY_ID" \
    -c test/s3_test_pipeline.yml -p s3test -n
fly -t "$ENVIRONMENT" unpause-pipeline -p s3test 

