#!/bin/bash

set -euo pipefail

: $ENVIRONMENT
if [ -z "${AWS_PROFILE:-}" ]; then
  : $AWS_ACCESS_KEY_ID
  : $AWS_SECRET_ACCESS_KEY
fi

[ -f "$VAR_FILE" ] ||
  aws s3 cp "s3://${ENVIRONMENT}-states/vpc/vars.tfvars" "$VAR_FILE" ||
  {
    echo "$VAR_FILE does not exist locally or in s3, please create manually";
    exit 1
  }
