#!/bin/bash

set -euo pipefail

while getopts 'e:f' option; do
  case $option in
    e) export ENVIRONMENT="$OPTARG";;
  esac
done
shift $((OPTIND-1))

: $ENVIRONMENT

STEP=${1:-base}

bin/get_states.sh -e $ENVIRONMENT -x -f $ENVIRONMENT-$STEP.tfstate

terraform output -state="data/$ENVIRONMENT-$STEP.tfstate" -json | jq '. | with_entries(.value = .value.value)'