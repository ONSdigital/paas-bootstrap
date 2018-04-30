#!/bin/bash

set -euo pipefail

aws s3 cp s3://"$ENVIRONMENT"-states/jumpbox/creds.yml "$ENVIRONMENT"_creds.yml

FQDN=$(bosh int --path /jumpbox_fqdn "$ENVIRONMENT"_creds.yml)
USERNAME=$(bosh int --path /jumpbox_user "$ENVIRONMENT"_creds.yml)
SSH_KEY=$(bosh int --path /ssh_key "$ENVIRONMENT"_creds.yml)

_keyfile=/var/tmp/tmp$$
echo "$SSH_KEY" > $_keyfile
chmod 600 $_keyfile
trap 'rm -f $_keyfile' EXIT

ssh -o BatchMode=yes -i $_keyfile "${USERNAME}@${FQDN}" "date"

