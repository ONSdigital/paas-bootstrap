#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

COMMAND=${1:-plan}
OPTS=
[ "$COMMAND" = plan ] || OPTS=-auto-approve

STATE="$ENVIRONMENT-base.tfstate"
ENV_VARS="$ENVIRONMENT.tfvars"

bin/get_states.sh -e $ENVIRONMENT -o -f $STATE -f $ENV_VARS
terraform init terraform/base
terraform $COMMAND $OPTS -var-file="data/$ENV_VARS" -state="data/$STATE" terraform/base/
bin/persist_states.sh -e $ENVIRONMENT -f $STATE -f $ENV_VARS
