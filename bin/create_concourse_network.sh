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

_tmp_vars=tmp$$.tfvars.json
trap 'rm -f $_tmp_vars' EXIT
STATE_FILE="$VPC_STATE_FILE" bin/tfstate_to_tfvars.sh >"$_tmp_vars"
_public_key=$(cat $PUBLIC_KEY_FILE)

aws s3 cp "s3://${ENVIRONMENT}-states/concourse/tfstate.json" "${CONCOURSE_TERRAFORM_STATE_FILE}" ||
  echo "Remote Concourse Terraform state does not exist. Assuming this is a new deployment"

terraform plan \
  -var "environment=$ENVIRONMENT" \
  -var "aws_access_key_id=$AWS_ACCESS_KEY_ID" \
  -var "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" \
  -var "public_key=$_public_key" \
  -var-file="$VAR_FILE" \
  -var-file="$_tmp_vars" \
  -state="$CONCOURSE_TERRAFORM_STATE_FILE" \
  terraform/concourse/aws

terraform apply -auto-approve \
  -var "environment=$ENVIRONMENT" \
  -var "aws_access_key_id=$AWS_ACCESS_KEY_ID" \
  -var "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" \
  -var "public_key=$_public_key" \
  -var-file="$VAR_FILE" \
  -var-file="$_tmp_vars" \
  -state="$CONCOURSE_TERRAFORM_STATE_FILE" \
  terraform/concourse/aws

aws s3 cp "${CONCOURSE_TERRAFORM_STATE_FILE}" "s3://${ENVIRONMENT}-states/concourse/tfstate.json" --acl=private
