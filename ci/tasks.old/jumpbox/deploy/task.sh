#!/bin/bash

set -euo pipefail

cp jumpbox-state-s3/jumpbox-state.json jumpbox-state/jumpbox-state.json

bosh create-env \
  jumpbox-manifests/jumpbox.yml \
  --state jumpbox-state/jumpbox-state.json