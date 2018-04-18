#!/bin/bash

set -eu

: ${VARS_FILE}
: ${VARS_STORE}
: ${STATE_FILE}

SUBMODULE=concourse-bosh-deployment

bosh create-env "$SUBMODULE" \
  -o "$SUBMODULE"/infrastructures/aws.yml \
  -o concourse/concourse-opts.yml \
  -l "$SUBMODULE"/versions.yml \
  -l "$VARS_FILE" \
  --vars-store "$VARS_STORE" \
  --state "$STATE_FILE"
  
