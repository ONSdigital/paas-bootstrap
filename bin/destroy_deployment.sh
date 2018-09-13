#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

DEPLOYMENT=$1

bin/get_states.sh -e $ENVIRONMENT

BOSH="bin/bosh_credentials.sh -e $ENVIRONMENT bosh"

echo "Deploying"
$BOSH delete-deployment -n -d $DEPLOYMENT