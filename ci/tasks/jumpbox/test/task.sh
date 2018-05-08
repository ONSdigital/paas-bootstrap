#!/bin/bash

set -euo pipefail
set -x

: $ENVIRONMENT

USERNAME=jumpbox
SSH_KEY=$(bosh int --path /jumpbox_ssh/private_key jumpbox-vars-s3/jumpbox-variables.yml)
INTERNAL_IP=$(bosh int --path /instance_groups/name=jumpbox/networks/name=private/static_ips/0 jumpbox-manifests/jumpbox.yml)

_keyfile=/var/tmp/tmp$$
echo "$SSH_KEY" > $_keyfile
chmod 600 $_keyfile
trap 'rm -f $_keyfile' EXIT

ssh -o BatchMode=yes -i $_keyfile "${USERNAME}@${INTERNAL_IP}" "date"

