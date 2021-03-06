#!/bin/bash

set -euo pipefail

: $ENVIRONMENT
: ${BRANCH:="$(git rev-parse --abbrev-ref HEAD)"}

echo "Using branch '${BRANCH}'"

bin/login_fly.sh

jumpbox_commit_ref="32c162b16f2a5a2639c78d905ba852487b93d507"
bosh_commit_ref="010bd498bb97dee707c167e60469b0f5d2cc90fb"

# Grab pre-requisite files from S3
aws s3 cp "s3://ons-paas-${ENVIRONMENT}-states/concourse/tfstate.json" "${CONCOURSE_TERRAFORM_STATE_FILE}"
aws s3 cp "s3://ons-paas-${ENVIRONMENT}-states/concourse/creds.yml" "${CONCOURSE_CREDS_FILE}"
aws s3 cp "s3://ons-paas-${ENVIRONMENT}-states/vpc/tfstate.json" "${VPC_STATE_FILE}"

REGION=$(terraform output -state="${ENVIRONMENT}_concourse.tfstate.json" region)
S3_KMS_KEY_ID=$(terraform output -state="${ENVIRONMENT}_concourse.tfstate.json" s3_kms_key_id)
DOMAIN=$(jq '.modules[0].outputs | with_entries(.value = .value.value)' "${VPC_STATE_FILE}" | jq -r '.dns_zone' | sed 's/\.$//')

fly -t "$ENVIRONMENT" set-pipeline \
    -v environment="$ENVIRONMENT" \
    -v branch="$BRANCH" \
    -v region="$REGION" \
    -v domain="$DOMAIN" \
    -v s3_kms_key_id="$S3_KMS_KEY_ID" \
    -v jumpbox_commit_ref="$jumpbox_commit_ref" \
    -v bosh_commit_ref="$bosh_commit_ref" \
    -c ci/destruction_pipeline.yml -p destruction_pipeline -n
fly -t "$ENVIRONMENT" unpause-pipeline -p destruction_pipeline

fly -t "$ENVIRONMENT" check-resource -r destruction_pipeline/bosh-deployment-git --from "ref:${bosh_commit_ref}"