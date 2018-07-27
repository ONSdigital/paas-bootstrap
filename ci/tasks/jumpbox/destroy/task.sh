#!/bin/bash

set -euo pipefail

cp jumpbox-state-s3/jumpbox-state.json jumpbox-state/jumpbox-state.json

bosh delete-env \
  jumpbox-manifest-s3/jumpbox.yml \
  --state jumpbox-state/jumpbox-state.json

echo '{}' > jumpbox-state/jumpbox-state.json
