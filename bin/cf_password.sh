#!/bin/bash

set -euo pipefail

while getopts e: option; do
  case $option in
    e) ENVIRONMENT="$OPTARG";;
  esac
done

: $ENVIRONMENT

bin/credhub_credentials.sh -e $ENVIRONMENT credhub get -n /bosh/cf/cf_admin_password -j | jq -r .value