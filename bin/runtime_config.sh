#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

output() {
    FILE=$1
    QUERY=$2

    bin/outputs.sh $FILE | jq -r "$QUERY"
}

BOSH="bin/bosh_credentials.sh -e $ENVIRONMENT bosh"
$BOSH update-runtime-config bosh-deployment/runtime-configs/dns.yml --name dns -n
