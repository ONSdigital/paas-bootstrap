#!/bin/bash

# Creates the Concourse AWS network environment, using the outputs from the create_vpc.sh step

set -euo pipefail

: $ENVIRONMENT
: $AWS_ACCESS_KEY_ID
: $AWS_SECRET_ACCESS_KEY
: $VPC_STATE_FILE
: $CONCOURSE_TERRAFORM_STATE_FILE
: $PUBLIC_KEY_FILE

local _tmp_vars=tmp$$.tfvars.json
trap 'rm -f $_tmp_vars' EXIT
STATE_FILE="$VPC_STATE_FILE" bin/tfstate_to_tfvars.sh >"$_tmp_vars"
local _public_key=$(cat $PUBLIC_KEY_FILE)

terraform plan \
  -var "environment=$ENVIRONMENT"
  -var "aws_access_key_id=$AWS_ACCESS_KEY_ID" \
  -var "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" \
  -var "public_key=$_public_key" \
  -var-file="$_tmp_vars" \
  -state=$CONCOURSE_TERRAFORM_STATE_FILE \
  terraform/concourse/aws

terraform apply -auto-approve \
  -var "environment=$ENVIRONMENT"
  -var "aws_access_key_id=$AWS_ACCESS_KEY_ID" \
  -var "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" \
  -var "public_key=$_public_key" \
  -var-file="$_tmp_vars" \
  -state=$CONCOURSE_TERRAFORM_STATE_FILE \
  terraform/concourse/aws
