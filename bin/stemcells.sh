#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

output() {
    FILE=$1
    QUERY=$2

    bin/outputs.sh $FILE | jq -r "$QUERY"
}
export IAAS_INFO=aws-xen-hvm
export STEMCELL_VERSION=$(bosh interpolate cf-deployment/cf-deployment.yml --path=/stemcells/alias=default/version)

BOSH="bin/bosh_credentials.sh -e $ENVIRONMENT bosh"
if ! $BOSH -n stemcells | grep -q "$STEMCELL_VERSION"; then
  $BOSH upload-stemcell https://bosh.io/d/stemcells/bosh-${IAAS_INFO}-ubuntu-trusty-go_agent?v=${STEMCELL_VERSION}
fi