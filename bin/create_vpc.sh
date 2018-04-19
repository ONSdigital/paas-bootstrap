#!/bin/bash

set -euo pipefail

: $ENVIRONMENT
: $VAR_FILE
: $VPC_STATE_FILE

TERRAFORM_DIR=terraform/aws

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
