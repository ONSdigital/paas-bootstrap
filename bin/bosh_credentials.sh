#!/bin/bash
#
# This script will set up a connection to a BOSH environment for you:
#
# - downloads from S3 the environment state files
# - sets up an SSH socks5 proxy (listening on BOSH_PROXY_PORT)
# - runs `bosh alias-env <env>`
# - exports the BOSH_CLIENT, BOSH_CLIENT_SECRET and BOSH_ALL_PROXY environment variables
#
# You can either run it in the foreground (-f), or source the script. In the first case, 
# you will run in a subshell and everything will be cleaned up when you exit that shell.
# In the second, you are responsible for killing the SSH proxy.

usage() {
    echo "Usage: [source] $(basename $0) -e <env> [-p ssh_port] [-f]"
    echo
    echo "Options:"
    echo "          -e  Connect to this environment, e.g. eng2 (ENVIRONMENT)"
    echo "          -p  Have SSH proxy listen on this port (BOSH_PROXY_PORT)"
    echo "          -f  Run this session in a shell, when you exit, the SSH proxy will be killed"
    exit 1
}

: ${BOSH_PROXY_PORT:=30123}
FOREGROUND=false

while getopts 'e:p:f' option; do
  case $option in
    e) ENVIRONMENT="$OPTARG";;
    p) BOSH_PROXY_PORT="$OPTARG";;
    f) FOREGROUND=true;;
    *) usage;;
  esac
done

VARS=/var/tmp/tmp$$
mkdir -p "$VARS"
trap 'rm -rf "$VARS"' EXIT

aws s3 cp "s3://${ENVIRONMENT}-states/vpc/tfstate.json" "$VARS/"
aws s3 cp "s3://${ENVIRONMENT}-states/jumpbox/jumpbox-variables.yml" "$VARS/"
aws s3 cp "s3://${ENVIRONMENT}-states/bosh/bosh-variables.yml" "$VARS/"
aws s3 cp "s3://${ENVIRONMENT}-states/bosh/bosh.yml" "$VARS/"
bosh int --path /jumpbox_ssh/private_key "$VARS/jumpbox-variables.yml" > "$VARS/jumpbox.key"
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "$VARS/tfstate.json" > "$VARS/vars.json"

ZONE=$(jq -r '.dns_zone' < "$VARS/vars.json" | sed 's/\.$//')
JUMPBOX_TARGET="jumpbox.${ZONE}"
chmod 600 "$VARS/jumpbox.key"
DIRECTOR_IP=$(bosh int --path '/cloud_provider/ssh_tunnel/host' "$VARS/bosh.yml")


if ! netstat -na | grep -q 127.0.0.1.${BOSH_PROXY_PORT}; then
  ssh -4 -D $BOSH_PROXY_PORT -fNC jumpbox@${JUMPBOX_TARGET} -i "${VARS}/jumpbox.key" && STARTED_SSH=true
fi

bosh int --path /default_ca/ca "$VARS/bosh-variables.yml" > "${VARS}/bosh_ca.pem"
BOSH_CA_CERT="${VARS}/bosh_ca.pem"

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh int --path /admin_password "$VARS/bosh-variables.yml")
export BOSH_ALL_PROXY=socks5://localhost:$BOSH_PROXY_PORT/

bosh alias-env "${ENVIRONMENT}" -e "${DIRECTOR_IP}"

if [ "$FOREGROUND" = true ]; then
  echo "OK, you are set up"
  export PS1="BOSH<$ENVIRONMENT>:\W \u\$ "
  bash
  if [ -n "$STARTED_SSH" ]; then
    echo "Killing the SSH proxy on $BOSH_PROXY_PORT"
    kill $(ps -ef | awk "/ssh -4 -D $BOSH_PROXY_PORT/ && ! /awk/ { print \$2 }")
  fi
fi