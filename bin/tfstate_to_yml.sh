#!/bin/bash

# This script will translate terraform outputs into .tfvars

set -eu

: $STATE_FILE

terraform output -state="$STATE_FILE" -json | yq r