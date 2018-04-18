#!/bin/bash

set -eu

: $VARS_FILE
: $CREDS_FILE
: $STATE_FILE

SUBMODULE=concourse-bosh-deployment

bosh create-env "$SUBMODULE"/lite/concourse.yml \
  -o "$SUBMODULE"/lite/infrastructures/aws.yml \
  -l "$SUBMODULE"/versions.yml \
  -l "$VARS_FILE" \
  --vars-store "$CREDS_FILE" \
  --state "$STATE_FILE"
  
