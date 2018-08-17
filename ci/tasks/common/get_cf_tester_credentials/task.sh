#!/usr/bin/env bash

set -euo pipefail

cat >cf_user_credentials/env <<-EOS
USER_ID=cf_tester
PASSWORD=$(bosh interpolate --path /cf_test_user_password cf-vars-s3/cf-variables.yml)
SYSTEM_DOMAIN=system.${DOMAIN}
APPS_DOMAIN=apps.${DOMAIN}
API=api.system.${DOMAIN}
EOS