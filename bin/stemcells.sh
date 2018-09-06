#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

output() {
    FILE=$1
    QUERY=$2

    bin/outputs.sh $FILE | jq -r "$QUERY"
}

IAAS_INFO=aws-xen-hvm
CF_STEMCELL_VERSION=$(bosh interpolate cf-deployment/cf-deployment.yml --path=/stemcells/alias=default/version)
CONCOURSE_STEMCELL_VERSION=97.15 # FIXME: interpolate from somewhere

BOSH="bin/bosh_credentials.sh -e $ENVIRONMENT bosh"
if ! $BOSH -n stemcells | grep -q "ubuntu-trusty.*$CF_STEMCELL_VERSION"; then
  $BOSH upload-stemcell https://bosh.io/d/stemcells/bosh-${IAAS_INFO}-ubuntu-trusty-go_agent?v=${CF_STEMCELL_VERSION}
fi

if ! $BOSH -n stemcells | grep -q "ubuntu-xenial.*$CONCOURSE_STEMCELL_VERSION"; then
  $BOSH upload-stemcell https://bosh.io/d/stemcells/bosh-${IAAS_INFO}-ubuntu-xenial-go_agent?v=${CONCOURSE_STEMCELL_VERSION}
fi