#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

terraform output -state="$ENVIRONMENT.tfstate" -json | jq '. | with_entries(.value = .value.value)'