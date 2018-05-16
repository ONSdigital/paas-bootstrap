#!/bin/bash
#
# This script will establish an SSH connection to the jumpbox
#

usage() {
    echo "Usage: [source] $(basename $0) -e <env> [ssh options]"
    echo
    echo "Options:"
    echo "          -e  Connect to this environment, e.g. eng2 (ENVIRONMENT)"
    exit 1
}

if [ "$1" = -? -o "$1" = --help ]; then
  usage
fi

if [ "$1" = -e ]; then
  ENVIRONMENT=$2
  shift 2
fi

VARS=/var/tmp/tmp$$
mkdir -p "$VARS"
trap 'rm -rf "$VARS"' EXIT

set -euo pipefail

aws s3 cp "s3://${ENVIRONMENT}-states/vpc/tfstate.json" "$VARS/"
aws s3 cp "s3://${ENVIRONMENT}-states/jumpbox/jumpbox-variables.yml" "$VARS/"
bosh int --path /jumpbox_ssh/private_key "$VARS/jumpbox-variables.yml" > "$VARS/jumpbox.key"
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "$VARS/tfstate.json" > "$VARS/vars.json"

ZONE=$(jq -r '.dns_zone' < "$VARS/vars.json" | sed 's/\.$//')
JUMPBOX_TARGET="jumpbox.${ZONE}"
chmod 600 "$VARS/jumpbox.key"

set +e

ssh jumpbox@${JUMPBOX_TARGET} -i "${VARS}/jumpbox.key" $*
