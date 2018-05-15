#!/bin/bash

set -eu

: $HOST
: $DOMAIN
: ${EXPECTED_OUTCOME:=success}

FQDN="$HOST.$DOMAIN"
RESOLVE=$(host "$FQDN" | awk '/has address/ { print $4 }')
CI_EIP=$(terraform output -state="concourse/tfstate.json" -json | jq -r 'with_entries(.value = .value.value) | .public_ip')

if [ "$RESOLVE" == "$CI_EIP" ]; then
  RESULT="success"
else 
  RESULT="failure"
fi

if [  "$RESULT" == "$EXPECTED_OUTCOME" ]; then
  echo -e "Resolved IP of $HOST.$DOMAIN matches its records in Bosh manifest."
  exit 0
else
  echo "Failed to match $HOST.$DOMAIN to its advertised IP address."
  exit 1
fi

