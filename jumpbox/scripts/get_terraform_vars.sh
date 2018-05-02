#!/bin/bash

set -euo pipefail

aws s3 cp "s3://${ENVIRONMENT}-states/vpc/tfstate.json" vpc.tfstate.json --sse 'aws:kms' \
    --sse-kms-key-id "${S3_KMS_KEY_ID}"

cat vpc.tfstate.json | jq '.modules[0].outputs | with_entries(.value = .value.value)' > vpc-vars/vars.json
