#!/bin/bash

set -euo pipefail

: $HOST
: $DOMAIN

FQDN="$HOST.$DOMAIN"
RESOLVE=$(host "$FQDN" | awk '/has address/ { print $4 }')
CONCOURSE_EIP=$(cat concourse-tfstate-s3/tfstate.json | jq -r ".modules[].outputs | with_entries(.value = .value.value) | .concourse_public_ip")

echo "FQDN: $FQDN, expect: $CONCOURSE_EIP, actual: $RESOLVE"
test "$RESOLVE" = "$CONCOURSE_EIP"