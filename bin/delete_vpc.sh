#!/bin/bash

set -euo pipefail

: $ENVIRONMENT
: $VAR_FILE
: $VPC_STATE_FILE

TERRAFORM_DIR=terraform/aws

terraform destroy -auto-approve -var-file="$VAR_FILE" -state="$VPC_STATE_FILE" "$TERRAFORM_DIR"
