#!/bin/bash

set -euo pipefail

while getopts e: option; do
  case $option in
    e) export ENVIRONMENT="$OPTARG";;
  esac
done

: $ENVIRONMENT

bin/login_fly.sh
bin/credhub_credentials.sh -e $ENVIRONMENT credhub set -n /concourse/main/cf_admin_password --type value --value $(bin/cf_password.sh -e $ENVIRONMENT)
bin/credhub_credentials.sh -e $ENVIRONMENT credhub set -n /concourse/main/bosh_admin_password --type value --value $(bin/bosh_password.sh -e $ENVIRONMENT)
