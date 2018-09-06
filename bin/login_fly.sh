#!/bin/bash

set -euo pipefail

USERNAME=admin

while getopts 'e:u:' option; do
  case $option in
    e) export ENVIRONMENT="$OPTARG";;
    u) USERNAME="$OPTARG";;
  esac
done

: $ENVIRONMENT

PASSWORD=$(bin/secret.sh -e $ENVIRONMENT -d concourse -k admin_password)
FQDN=$(bin/outputs.sh base | jq -r .concourse_fqdn)

fly login -t "$ENVIRONMENT" -u "$USERNAME" -p "$PASSWORD" -c "https://$FQDN"