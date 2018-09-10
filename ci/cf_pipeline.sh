#!/bin/bash

set -euo pipefail

: $ENVIRONMENT
: ${BRANCH:="$(git rev-parse --abbrev-ref HEAD)"}

echo "Using branch '${BRANCH}'"

DOMAIN="$(bin/outputs.sh base | jq -r .domain)"
REGION="$(bin/outputs.sh base | jq -r .region)"
KMS_KEY_ID="$(bin/outputs.sh base | jq -r .states_s3_kms_key_id)"

CATS_TAG="v1.6.0"
CF_TAG="v4.0.0"
PROMETHEUS_TAG="v23.2.0"

fly -t "$ENVIRONMENT" set-pipeline \
    -v environment="$ENVIRONMENT" \
    -v region="$REGION" \
    -v branch="$BRANCH" \
    -v domain="$DOMAIN" \
    -v cats_tag="$CATS_TAG" \
    -v cf_tag="$CF_TAG" \
    -v prometheus_tag="$PROMETHEUS_TAG" \
    -v s3_kms_key_id="$KMS_KEY_ID" \
    -c ci/cf.yml -p cf -n

fly -t "$ENVIRONMENT" unpause-pipeline -p cf
fly -t "$ENVIRONMENT" expose-pipeline -p cf

fly -t "$ENVIRONMENT" check-resource -r cf/cf-acceptance-tests-git --from "ref:${CATS_TAG}"
fly -t "$ENVIRONMENT" check-resource -r cf/cf-deployment-git --from "ref:${CF_TAG}"
fly -t "$ENVIRONMENT" check-resource -r cf/prometheus-boshrelease-git --from "ref:${PROMETHEUS_TAG}"