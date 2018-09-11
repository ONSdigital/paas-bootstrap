#!/bin/bash

set -eu

: $ENVIRONMENT

output() {
    FILE=$1
    QUERY=$2

    FILE="${FILE}-tfstate-s3/${ENVIRONMENT}-${FILE}.tfstate"
    jq -r ".modules[0].outputs | with_entries(.value = .value.value) | $QUERY" <"$FILE"
}


export BOSH_ENVIRONMENT=$(output base .bosh_private_ip)

IAAS_INFO=aws-xen-hvm
CF_STEMCELL_VERSION=$(bosh interpolate cf-deployment/cf-deployment.yml --path=/stemcells/alias=default/version)

bosh upload-stemcell https://bosh.io/d/stemcells/bosh-${IAAS_INFO}-ubuntu-trusty-go_agent?v=${CF_STEMCELL_VERSION}