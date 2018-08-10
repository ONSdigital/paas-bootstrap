#!/usr/bin/env bash

set -euo pipefail

cat >cf_mgmt_vars/env <<-EOS
USER_ID=cf_mgmt
CLIENT_SECRET=$(bosh interpolate --path /uaa_clients_cf_mgmt_secret cf-vars-s3/cf-variables.yml)
SYSTEM_DOMAIN=system.$DOMAIN
EOS