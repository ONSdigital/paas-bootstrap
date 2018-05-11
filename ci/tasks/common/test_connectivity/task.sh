#!/bin/bash

set -euo pipefail

: $PORT
: $HOST
: $DOMAIN

FQDN="$HOST.$DOMAIN"

echo "foo" | nc -w 1 "$FQDN" "$PORT" 

