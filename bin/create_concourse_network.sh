#!/bin/bash

# Creates the Concourse AWS network environment, using the outputs from the create_vpc.sh step

set -euo pipefail

: ${VPC_STATE_FILE:=vpc.tfstate.json}
: ${STATE_FILE:=concourse.tfstate.json}
: $SECRET_FILE
: $PUBLIC_KEY_FILE

TMP_VARS=tmp$$.tfvars.json
trap 'rm -f $TMP_VARS' EXIT
STATE_FILE="$VPC_STATE_FILE" bin/tfstate_to_tfvars.sh >"$TMP_VARS"
PUBLIC_KEY=$(cat $PUBLIC_KEY_FILE)

terraform plan -var "public_key=$PUBLIC_KEY" -var-file="$TMP_VARS" -var-file="$SECRET_FILE" -state=$STATE_FILE terraform/concourse/aws
terraform apply -auto-approve -var "public_key=$PUBLIC_KEY" -var-file="$TMP_VARS" -var-file="$SECRET_FILE" -state=$STATE_FILE terraform/concourse/aws