#!/bin/bash

set -euo pipefail

: $ENVIRONMENT
: $AWS_ACCESS_KEY_ID
: $AWS_SECRET_ACCESS_KEY

[ -f "$VAR_FILE" ] || { echo "$VAR_FILE does not exist"; exit 1; }