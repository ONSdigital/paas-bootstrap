#!/bin/bash

set -eu

: $DOMAIN
: $CF_ADMIN_PASSWORD

cat $CATS_CONFIG_FILE | jq "
.api = \"api.system.${DOMAIN}\" | 
.apps_domain = \"apps.${DOMAIN}\" |
.admin_user = \"admin\" |
.admin_password = \"${CF_ADMIN_PASSWORD}\"
" > integration-config/integration_config.json
