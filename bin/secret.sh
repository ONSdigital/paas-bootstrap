#!/bin/bash

set -euo pipefail

while getopts e:d:k: option; do
  case $option in
    e) ENVIRONMENT="$OPTARG";;
    d) DEPLOYMENT="$OPTARG";;
    k) KEY="$OPTARG";;
  esac
done

: $ENVIRONMENT

bin/credhub_credentials.sh -e $ENVIRONMENT credhub get -n "/bosh/$DEPLOYMENT/$KEY" -j | jq -r .value