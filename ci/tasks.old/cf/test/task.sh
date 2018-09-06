#!/bin/bash

set -euo pipefail

: $HOST
: $DOMAIN

FQDN="$HOST.$DOMAIN"
RESOLVE=$(host "$FQDN" | awk '/has address/ { print $4 }')

echo "FQDN: $FQDN"
test -n "$RESOLVE"