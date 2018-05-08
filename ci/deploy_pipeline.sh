#!/bin/bash

set -euo pipefail
set -x
: $ENVIRONMENT

bin/login_fly.sh

jumpbox_commit_ref="32c162b16f2a5a2639c78d905ba852487b93d507"

# Grab pre-requisite files from S3
aws s3 cp "s3://${ENVIRONMENT}-states/concourse/tfstate.json" "${CONCOURSE_TERRAFORM_STATE_FILE}"
aws s3 cp "s3://${ENVIRONMENT}-states/concourse/creds.yml" "${CONCOURSE_CREDS_FILE}"

REGION=$(terraform output -state=${ENVIRONMENT}_concourse.tfstate.json region)
S3_KMS_KEY_ID=$(terraform output -state=${ENVIRONMENT}_concourse.tfstate.json s3_kms_key_id)

fly -t "$ENVIRONMENT" set-pipeline \
    -v environment="$ENVIRONMENT" \
    -v region="$REGION" \
    -v s3_kms_key_id="$S3_KMS_KEY_ID" \
    -v jumpbox_commit_ref="$jumpbox_commit_ref" \
    -c ci/deploy_pipeline.yml -p deploy_pipeline -n
fly -t "$ENVIRONMENT" unpause-pipeline -p deploy_pipeline

fly -t "$ENVIRONMENT" check-resource -r deploy_pipeline/jumpbox-deployment-git --from "ref:${jumpbox_commit_ref}"
