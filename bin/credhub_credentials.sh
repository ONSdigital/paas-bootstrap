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

PROXY_PORT=30125
JUMPBOX_IP=$(bin/outputs.sh base | jq -r .jumpbox_public_ip)
JUMPBOX_KEY=~/.ssh/$ENVIRONMENT.jumpbox.$$.pem
bin/outputs.sh base | jq -r .jumpbox_private_key >$JUMPBOX_KEY
chmod 600 $JUMPBOX_KEY
export CREDHUB_CA_CERT=/var/tmp/credhub_ca.$$.pem
bosh int --path /credhub_ca/ca "data/$ENVIRONMENT-bosh-variables.yml" >$CREDHUB_CA_CERT
export UAA_CA_CERT=/var/tmp/uaa_ca.$$.pem
bosh int --path /uaa_ssl/ca "data/$ENVIRONMENT-bosh-variables.yml" >$UAA_CA_CERT

cleanup() {
  rm -f $JUMPBOX_KEY
  rm -f $CREDHUB_CA_CERT
  rm -f $UAA_CA_CERT

  if [ -n "$STARTED_SSH" ]; then
    echo "Killing the SSH proxy on $PROXY_PORT"
    kill $(ps -ef | awk "/ssh -4 -D $PROXY_PORT/ && ! /awk/ { print \$2 }")
  fi
}
trap cleanup EXIT

if ! netstat -na | grep -q "127.0.0.1.${PROXY_PORT}.*LISTEN"; then
  ssh -4 -D $PROXY_PORT -fNC ubuntu@${JUMPBOX_IP} -i "$JUMPBOX_KEY" && STARTED_SSH=true
fi

export CREDHUB_SERVER=https://$(bin/outputs.sh base | jq -r .bosh_private_ip):8844
export CREDHUB_CLIENT=credhub-admin
export CREDHUB_SECRET=$(bosh int --path /credhub_admin_client_secret "data/$ENVIRONMENT-bosh-variables.yml")
export HTTPS_PROXY=socks5://localhost:$PROXY_PORT

if [ -n "$COMMAND" ]; then
  ""$COMMAND""
else
  echo "OK, you are set up"
  export PS1="CREDHUB<$ENVIRONMENT>:\W \u\$ "
  bash
fi