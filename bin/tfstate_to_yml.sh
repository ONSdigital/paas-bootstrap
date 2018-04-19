#!/bin/bash

# This script will translate terraform outputs into .tfvars

set -euo pipefail

: $STATE_FILE

terraform output -state="$STATE_FILE" -json | yq r