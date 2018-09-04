#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

COMMAND=${1:-plan}
OPTS=
[ "$COMMAND" = plan ] || OPTS=-auto-approve

terraform init terraform/base
terraform $COMMAND $OPTS -var-file="data/$ENVIRONMENT.tfvars" -state="data/$ENVIRONMENT.tfstate" terraform/base/
