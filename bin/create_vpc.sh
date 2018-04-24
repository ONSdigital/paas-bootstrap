#!/bin/bash

set -euo pipefail

: $ENVIRONMENT
: $VAR_FILE
: $VPC_STATE_FILE

TERRAFORM_DIR=terraform/aws

aws s3 cp "s3://${ENVIRONMENT}-states/vpc/tfstate.json" "${VPC_STATE_FILE}" ||
  echo "Remote VPC Terraform state does not exist. Assuming this is a new deployment"

terraform init "$TERRAFORM_DIR"
terraform plan \
  -var "environment=$ENVIRONMENT" \
  -var "aws_access_key_id=$AWS_ACCESS_KEY_ID" \
  -var "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" \
  -var-file="$VAR_FILE" \
  -state="$VPC_STATE_FILE" \
  "$TERRAFORM_DIR"

terraform apply -auto-approve \
  -var "environment=$ENVIRONMENT" \
  -var "aws_access_key_id=$AWS_ACCESS_KEY_ID" \
  -var "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" \
  -var-file="$VAR_FILE" \
  -state="$VPC_STATE_FILE" \
  "$TERRAFORM_DIR"

aws s3 cp "${VPC_STATE_FILE}" "s3://${ENVIRONMENT}-states/vpc/tfstate.json"
aws s3 cp "${VAR_FILE}" "s3://${ENVIRONMENT}-states/vpc/vars.tfvars"
