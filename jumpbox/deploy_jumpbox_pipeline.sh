#!/bin/bash

set -euo pipefail
set -x
: $ENVIRONMENT

bin/login_fly.sh

fly -t "$ENVIRONMENT" set-pipeline \
    -v environment="$ENVIRONMENT" \
    -c jumpbox/pipeline.yml -p jumpbox -n
fly -t "$ENVIRONMENT" unpause-pipeline -p jumpbox 

