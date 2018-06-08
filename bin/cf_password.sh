#!/bin/bash

set -euo pipefail

while getopts e: option; do
  case $option in
    e) ENVIRONMENT="$OPTARG";;
  esac
done

: $ENVIRONMENT

PASSPATH='/instance_groups/name=uaa/jobs/name=uaa/properties/uaa/scim/users/name=admin/password'
bosh int --path $PASSPATH <(aws s3 cp "s3://${ENVIRONMENT}-states/cf/cf.yml" -)