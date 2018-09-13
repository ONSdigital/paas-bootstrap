#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

COMMAND=${1:-plan}
OPTS=
[ "$COMMAND" = plan ] || OPTS=-auto-approve

bin/get_states.sh -e $ENVIRONMENT -o -f $ENVIRONMENT.tfvars -f $ENVIRONMENT-rds.tfstate

terraform init terraform/rds

terraform $COMMAND \
  $OPTS \
  -var-file="data/$ENVIRONMENT.tfvars" \
  -var-file=<(bin/outputs.sh base) \
  -state="data/$ENVIRONMENT-rds.tfstate" terraform/rds/

bin/persist_states.sh -e $ENVIRONMENT -f $ENVIRONMENT-rds.tfstate