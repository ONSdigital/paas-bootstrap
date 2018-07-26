#!/bin/bash

set -euo pipefail

jq '.modules[0].outputs | with_entries(.value = .value.value)' < vpc-tfstate-s3/tfstate.json > vpc-vars/vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "bosh-tfstate-s3/${ENVIRONMENT}.tfstate" > bosh-vars/vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "cf-tfstate-s3/${ENVIRONMENT}.tfstate" > cf-vars/vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "jumpbox-tfstate-s3/${ENVIRONMENT}.tfstate" > jumpbox-vars/vars.json