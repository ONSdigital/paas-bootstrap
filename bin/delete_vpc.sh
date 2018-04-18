#!/bin/bash

set -eu

: $VAR_FILE
: ${STATE_FILE:=vpc.tfstate.json}

TERRAFORM_DIR=terraform/aws

terraform destroy -auto-approve -var-file="$VAR_FILE" -state="$STATE_FILE" "$TERRAFORM_DIR"
