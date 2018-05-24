#!/bin/bash

set -euo pipefail

: $DOMAIN
: $HOST
: ${QUERY_PATH=/}
: ${REQUIRE_JSON:=false}

URL="https://${HOST}.${DOMAIN}${QUERY_PATH}"
if [ "$REQUIRE_JSON" = true ]; then
  wget -O - -nv  -t 1 -T 5 --header='Accept: application/json' "$URL"
else
  wget -O - -nv  -t 1 -T "$URL"
fi