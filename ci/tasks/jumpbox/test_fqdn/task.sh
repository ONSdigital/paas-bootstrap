#!/bin/bash

set -eu

: $HOST
: $DOMAIN
: ${EXPECTED_OUTCOME:=success}

FQDN="$HOST.$DOMAIN"
RESOLVE=$(host "$FQDN" | awk '/has address/ { print $4 }')
JUMPBOX_EIP=$(bosh int --path /instance_groups/name=jumpbox/networks/name=public/static_ips/0 jumpbox-manifest-s3/jumpbox.yml)

if [ "$RESOLVE" == "$JUMPBOX_EIP" ]; then
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

