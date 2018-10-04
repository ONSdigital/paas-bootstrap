#!/bin/bash

set -euo pipefail

: $ENVIRONMENT
: ${BRANCH:="$(git rev-parse --abbrev-ref HEAD)"}

echo "Using branch '${BRANCH}'"

bin/login_fly.sh

jumpbox_commit_ref="32c162b16f2a5a2639c78d905ba852487b93d507"
bosh_commit_ref="04c85a5c79a9fa6b92775386a334104b9a165013"
prometheus_commit_ref="a381c0af550550fc1d740ef409c2e2f22a589202"
cf_tag="v2.7.0"
rabbitmq_broker_tag="v37.0.0"

node_exporter_version="4.0.0"

# Grab pre-requisite files from S3
aws s3 cp "s3://ons-paas-${ENVIRONMENT}-states/concourse/tfstate.json" "${CONCOURSE_TERRAFORM_STATE_FILE}"
aws s3 cp "s3://ons-paas-${ENVIRONMENT}-states/concourse/creds.yml" "${CONCOURSE_CREDS_FILE}"
aws s3 cp "s3://ons-paas-${ENVIRONMENT}-states/vpc/tfstate.json" "${VPC_STATE_FILE}"

REGION=$(terraform output -state="${ENVIRONMENT}_concourse.tfstate.json" region)
S3_KMS_KEY_ID=$(terraform output -state="${ENVIRONMENT}_concourse.tfstate.json" s3_kms_key_id)
DOMAIN=$(jq '.modules[0].outputs | with_entries(.value = .value.value)' "${VPC_STATE_FILE}" | jq -r '.dns_zone' | sed 's/\.$//')
slack_webhook_uri=$(jq -r .slack_webhook_uri < "$VAR_FILE")

fly -t "$ENVIRONMENT" set-pipeline \
    -v environment="$ENVIRONMENT" \
    -v branch="$BRANCH" \
    -v region="$REGION" \
    -v domain="$DOMAIN" \
    -v s3_kms_key_id="$S3_KMS_KEY_ID" \
    -v jumpbox_commit_ref="$jumpbox_commit_ref" \
    -v bosh_commit_ref="$bosh_commit_ref" \
    -v cf_tag="$cf_tag" \
    -v slack_webhook_uri="$slack_webhook_uri" \
    -v prometheus_commit_ref="$prometheus_commit_ref" \
    -v node_exporter_version="$node_exporter_version" \
    -v rabbitmq_broker_tag="$rabbitmq_broker_tag" \
    -v cf_deployment_name="cf" \
    -c ci/deploy_pipeline.yml -p deploy_pipeline -n

fly -t "$ENVIRONMENT" unpause-pipeline -p deploy_pipeline
fly -t "$ENVIRONMENT" expose-pipeline -p deploy_pipeline

fly -t "$ENVIRONMENT" check-resource -r deploy_pipeline/jumpbox-deployment-git --from "ref:${jumpbox_commit_ref}"
fly -t "$ENVIRONMENT" check-resource -r deploy_pipeline/bosh-deployment-git --from "ref:${bosh_commit_ref}"
fly -t "$ENVIRONMENT" check-resource -r deploy_pipeline/cf-deployment-git --from "ref:${cf_tag}"
fly -t "$ENVIRONMENT" check-resource -r deploy_pipeline/rabbitmq-broker-deployment-git --from "ref:${rabbitmq_broker_tag}"
fly -t "$ENVIRONMENT" check-resource -r deploy_pipeline/prometheus-deployment-git --from "ref:${prometheus_commit_ref}"