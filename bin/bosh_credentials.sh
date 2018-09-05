#!/bin/bash
#
# This script will set up a connection to a BOSH environment for you:

usage() {
    echo "Usage: [source] $(basename $0) -e <env> [command]"
    echo
    echo "Options:"
    echo "          -e  Connect to this environment, e.g. eng2 (ENVIRONMENT)"
    echo
    echo "              If you specify a command, it will run, then detach the proxy"
    echo "              otherwise, you will be placed in a shell with the environment set"
    exit 1
}


while getopts 'e:f' option; do
  case $option in
    e) ENVIRONMENT="$OPTARG";;
    *) usage;;
  esac
done
export ENVIRONMENT

shift $((OPTIND-1))
COMMAND=$*

JUMPBOX_IP=$(bin/outputs.sh base | jq -r .jumpbox_public_ip)
JUMPBOX_KEY=~/.ssh/$ENVIRONMENT.jumpbox.$$.pem
bin/outputs.sh base | jq -r .jumpbox_private_key >$JUMPBOX_KEY
chmod 600 $JUMPBOX_KEY
export BOSH_CA_CERT=/var/tmp/bosh_ca.$$.pem
bosh int --path /default_ca/ca "data/$ENVIRONMENT-bosh-variables.yml" >$BOSH_CA_CERT

cleanup() {
  rm -f $JUMPBOX_KEY
  rm -f $BOSH_CA_CERT
}
trap cleanup EXIT


export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh int --path /admin_password "data/$ENVIRONMENT-bosh-variables.yml")
export BOSH_ENVIRONMENT=$(bin/outputs.sh base | jq -r .bosh_private_ip)
export BOSH_ALL_PROXY=ssh+socks5://ubuntu@$JUMPBOX_IP:22?private-key=$JUMPBOX_KEY

if [ -n "$COMMAND" ]; then
  ""$COMMAND""
else
  echo "OK, you are set up"
  export PS1="BOSH<$ENVIRONMENT>:\W \u\$ "
  bash
fi