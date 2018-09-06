#!/bin/bash

set -euo pipefail

: $HOST
: $DOMAIN

FQDN="$HOST.$DOMAIN"
RESOLVE=$(host "$FQDN" | awk '/has address/ { print $4 }')
JUMPBOX_EIP=$(bosh int --path /instance_groups/name=jumpbox/networks/name=public/static_ips/0 jumpbox-manifest-s3/jumpbox.yml)

echo "FQDN: $FQDN, expect: $JUMPBOX_EIP, actual: $RESOLVE"
test "$RESOLVE" = "$JUMPBOX_EIP"


