#!/usr/bin/env bash

set -euo pipefail

cat >cf_user_credentials/env <<-EOS
USER_ID=cf_tester
PASSWORD=$(bosh interpolate --path /cf_tester_password cf-vars-s3/cf-variables.yml)
SYSTEM_DOMAIN=system.$DOMAIN
APPS_DOMAIN=apps.$DOMAIN
EOS