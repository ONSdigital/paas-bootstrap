#!/bin/bash

set -euo pipefail

cp bosh-state-s3/bosh-state.json bosh-state/bosh-state.json

bosh delete-env \
  bosh-manifests/bosh.yml \
  --state bosh-state/bosh-state.json