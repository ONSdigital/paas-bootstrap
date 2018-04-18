#!/bin/bash

set -eu

: $VAR_FILE
: $STATE_FILE

TERRAFORM_DIR=terraform

terraform init "$TERRAFORM_DIR"
terraform plan -var-file="$VAR_FILE" -state="$STATE_FILE" "$TERRAFORM_DIR"
terraform apply -var-file="$VAR_FILE" -state="$STATE_FILE" "$TERRAFORM_DIR"
