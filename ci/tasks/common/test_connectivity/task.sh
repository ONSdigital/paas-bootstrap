#!/bin/bash

set -euo pipefail

: $PORT
: $HOST
: $DOMAIN
: ${EXPECTED_OUTCOME:=success}

FQDN="$HOST.$DOMAIN"

echo "ATTEMPTING $FQDN"

set +e
echo "foo" | nc -w 1 "$FQDN" "$PORT" 
RESULT=$?
if [ "$EXPECTED_OUTCOME" = success ]; then
  exit $RESULT
elif [ "$RESULT" = 0 ]; then
  exit 1
fi
exit 0

