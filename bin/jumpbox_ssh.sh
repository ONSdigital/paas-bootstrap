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
export ENVIRONMENT

JUMPBOX_IP=$(bin/outputs.sh base | jq -r .jumpbox_public_ip)
JUMPBOX_KEY=~/.ssh/$ENVIRONMENT.jumpbox.$$.pem
bin/outputs.sh base | jq -r .jumpbox_private_key >$JUMPBOX_KEY
chmod 600 $JUMPBOX_KEY

cleanup() {
  rm -f $JUMPBOX_KEY
}
trap cleanup EXIT

set +e

ssh -o "IdentitiesOnly=yes" ubuntu@${JUMPBOX_IP} -i $JUMPBOX_KEY $*
