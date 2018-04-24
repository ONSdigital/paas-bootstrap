#!/bin/bash

# This script will translate terraform outputs into .tfvars

set -euo pipefail

: $STATE_FILE

terraform output -state="$STATE_FILE" -json | jq 'with_entries(.value = .value.value)'
