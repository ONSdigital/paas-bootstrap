#!/bin/bash

# Creates the Concourse AWS network environment, using the outputs from the create_vpc.sh step

set -euo pipefail

: $ENVIRONMENT
: $AWS_ACCESS_KEY_ID
: $AWS_SECRET_ACCESS_KEY
: ${JUMPBOX_TERRAFORM_STATE_FILE:=${ENVIRONMENT}_jumpbox.tfstate.json}
: ${VPC_STATE_FILE:=${ENVIRONMENT}_vpc.tfstate.json}
: $VAR_FILE

aws s3 cp "s3://${ENVIRONMENT}-states/vpc/tfstate.json" "${VPC_STATE_FILE}"
aws s3 cp "s3://${ENVIRONMENT}-states/jumpbox/tfstate.json" "${JUMPBOX_TERRAFORM_STATE_FILE}" ||
  echo "Remote Jumpbox Terraform state does not exist. Assuming this is a new deployment"

_tmp_vars=tmp$$.tfvars.json
trap 'rm -f $_tmp_vars' EXIT
STATE_FILE="$VPC_STATE_FILE" bin/tfstate_to_tfvars.sh >"$_tmp_vars"

terraform plan \
  -var "environment=$ENVIRONMENT" \
  -var "aws_access_key_id=$AWS_ACCESS_KEY_ID" \
  -var "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" \
  -var-file="$_tmp_vars" \
  -var-file="$VAR_FILE" \
  -state="$JUMPBOX_TERRAFORM_STATE_FILE" \
  terraform/jumpbox/aws

terraform apply -auto-approve \
  -var "environment=$ENVIRONMENT" \
  -var "aws_access_key_id=$AWS_ACCESS_KEY_ID" \
  -var "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" \
  -var-file="$_tmp_vars" \
  -var-file="$VAR_FILE" \
  -state="$JUMPBOX_TERRAFORM_STATE_FILE" \
  terraform/jumpbox/aws

aws s3 cp "${JUMPBOX_TERRAFORM_STATE_FILE}" "s3://${ENVIRONMENT}-states/jumpbox/tfstate.json" --acl=private
