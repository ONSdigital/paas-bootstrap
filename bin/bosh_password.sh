#!/bin/bash
#
# Returns the current BOSH password

while getopts 'e:' option; do
  case $option in
    e) export ENVIRONMENT="$OPTARG";;
  esac
done

: $ENVIRONMENT

bin/get_states.sh -e $ENVIRONMENT -x -f $ENVIRONMENT-bosh-variables.yml
bosh int --path /admin_password "data/$ENVIRONMENT-bosh-variables.yml" | head -1
