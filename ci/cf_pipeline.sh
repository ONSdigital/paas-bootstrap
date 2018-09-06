#!/bin/bash

set -euo pipefail

: $ENVIRONMENT
: ${BRANCH:="$(git rev-parse --abbrev-ref HEAD)"}

echo "Using branch '${BRANCH}'"

DOMAIN="$(bin/outputs.sh base | jq -r .domain)"

fly -t "$ENVIRONMENT" set-pipeline \
    -v environment="$ENVIRONMENT" \
    -v branch="$BRANCH" \
    -v domain="$DOMAIN" \
    -c ci/cf.yml -p cf -n

fly -t "$ENVIRONMENT" unpause-pipeline -p cf
fly -t "$ENVIRONMENT" expose-pipeline -p cf
