#!/bin/bash

set -eu

: $DOMAIN

ADMIN_PASSWORD="$(bosh int cf-vars-s3/cf-variables.yml --path /cf_admin_password)"

cat $CATS_CONFIG_FILE | jq "
.api = \"api.system.${DOMAIN}\" | 
.apps_domain = \"apps.${DOMAIN}\" |
.admin_user = \"admin\" |
.admin_password = \"${ADMIN_PASSWORD}\"
" > integration-config/integration_config.json
