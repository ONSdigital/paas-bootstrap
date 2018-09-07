#!/bin/bash

set -euo pipefail

: $ENVIRONMENT
: $AWS_ACCESS_KEY_ID
: $AWS_SECRET_ACCESS_KEY
: ${VERIFY:=true}

output() {
    FILE=$1
    QUERY=$2

    bin/outputs.sh $FILE | jq -r "$QUERY"
}

if [ "$VERIFY" = true ]; then
    echo "This is probably a bad idea. Of course, all of the important stuff *should* be in the bosh database, but you ought to be well confident that you want to do this"
    echo
    echo "So do ya, punk? (only 'yes' is acceptable)"
    read ans
    case $ans in
        [Yy][Ee][Ss]);;
        *) echo "Bailing out"; exit 1;;
    esac
fi

bin/get_states.sh -e $ENVIRONMENT

JUMPBOX_IP=$(output base .jumpbox_public_ip)
JUMPBOX_KEY=~/.ssh/$ENVIRONMENT.jumpbox.$$.pem
output base .jumpbox_private_key >$JUMPBOX_KEY
chmod 600 $JUMPBOX_KEY

cleanup() {
    rm -f $JUMPBOX_KEY
}
trap cleanup EXIT

export BOSH_ALL_PROXY=ssh+socks5://ubuntu@$JUMPBOX_IP:22?private-key=$JUMPBOX_KEY

bosh delete-env \
  data/$ENVIRONMENT-bosh-manifest.yml \
  --state data/$ENVIRONMENT-bosh-state.json

echo "{}" >data/$ENVIRONMENT-bosh-state.json
bin/persist_states.sh -e $ENVIRONMENT -f $ENVIRONMENT-bosh-state.json