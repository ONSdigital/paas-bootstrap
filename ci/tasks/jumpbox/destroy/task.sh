#!/bin/bash

set -euo pipefail

jq '.modules[0].outputs | with_entries(.value = .value.value)' < vpc-tfstate-s3/tfstate.json > vpc-vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < concourse-tfstate-s3/tfstate.json > concourse-vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "jumpbox-tfstate-s3/${ENVIRONMENT}.tfstate" > jumpbox-vars.json

cp jumpbox-state-s3/jumpbox-state.json jumpbox-state/jumpbox-state.json

bosh delete-env \
  jumpbox-manifest-s3/jumpbox.yml \
  --state jumpbox-state/jumpbox-state.json

echo '{}' > jumpbox-state/jumpbox-state.json
