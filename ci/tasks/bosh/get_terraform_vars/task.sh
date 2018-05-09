#!/bin/bash

set -euo pipefail

cat vpc-tfstate-s3/tfstate.json | jq '.modules[0].outputs | with_entries(.value = .value.value)' > vpc-vars/vars.json
