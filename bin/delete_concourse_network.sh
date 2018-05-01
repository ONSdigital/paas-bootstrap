#!/bin/bash

# Creates the Concourse AWS network environment, using the outputs from the create_vpc.sh step

set -euo pipefail

: $ENVIRONMENT
: $AWS_ACCESS_KEY_ID
: $AWS_SECRET_ACCESS_KEY
: $VPC_STATE_FILE
: $CONCOURSE_TERRAFORM_STATE_FILE
: $PUBLIC_KEY_FILE
: $VAR_FILE

TERRAFORM_DIR=terraform/concourse/aws

aws s3 cp "s3://${ENVIRONMENT}-states/concourse/ssh-key.pem.pub" "${PUBLIC_KEY_FILE}" ||
  {
    echo "Remote SSH key does not exist. Assuming the deployment does not exist";
    exit 0
  }
_public_key=$(cat $PUBLIC_KEY_FILE)

aws s3 cp "s3://${ENVIRONMENT}-states/concourse/tfstate.json" "${CONCOURSE_TERRAFORM_STATE_FILE}" ||
  {
    echo "Remote Concourse Terraform state does not exist. Assuming the deployment does not exist";
    exit 0
  }

_tmp_vars=tmp$$.tfvars.json
trap 'rm -f $_tmp_vars' EXIT
STATE_FILE="$VPC_STATE_FILE" bin/tfstate_to_tfvars.sh >"$_tmp_vars"

terraform init "$TERRAFORM_DIR"
terraform destroy -auto-approve \
  -var "environment=$ENVIRONMENT" \
  -var "aws_access_key_id=$AWS_ACCESS_KEY_ID" \
  -var "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" \
  -var "public_key=$_public_key" \
  -var-file="$VAR_FILE" \
  -var-file="$_tmp_vars" \
  -state="$CONCOURSE_TERRAFORM_STATE_FILE" \
  "$TERRAFORM_DIR"

aws s3 rm "s3://${ENVIRONMENT}-states/concourse/tfstate.json" || true
rm "${CONCOURSE_TERRAFORM_STATE_FILE}" || true
aws s3 rm "s3://${ENVIRONMENT}-states/concourse/ssh-key.pem" || true
rm "${PRIVATE_KEY_FILE}" || true
aws s3 rm "s3://${ENVIRONMENT}-states/concourse/ssh-key.pem.pub" || true
rm "${PUBLIC_KEY_FILE}" || true
