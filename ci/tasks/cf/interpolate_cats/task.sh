#!/bin/bash

set -euo pipefail

# jq '.modules[0].outputs | with_entries(.value = .value.value)' < "cf-tfstate-s3/${ENVIRONMENT}.tfstate" > cf-vars.json

: $DOMAIN

cat profiles/staging/cats_config.json | jq "
.api = \"api.system.${DOMAIN}\" | 
.apps_domain = \"apps.${DOMAIN}\"
"
