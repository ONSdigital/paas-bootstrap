#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

LOCAL_PORT=30201
DB_USER=$(bin/outputs.sh rds | jq -r .bosh_db_username)
DB_HOST=$(bin/outputs.sh rds | jq -r .bosh_db_host)
DB_PORT=$(bin/outputs.sh rds | jq -r .bosh_db_port)
DB_PASS=$(bin/outputs.sh rds | jq -r .bosh_rds_password)
JUMPBOX_IP=$(bin/outputs.sh | jq -r .jumpbox_public_ip)
KEYFILE=~/.ssh/jumpbox.$$.pem
bin/outputs.sh | jq -r .jumpbox_private_key >$KEYFILE
chmod 600 $KEYFILE

cleanup() {
    rm -f $KEYFILE
    kill $(ps -ef | awk "/ssh.*$LOCAL_PORT/ && ! /awk/ { print \$2 }")
}
ssh -fN -L $LOCAL_PORT:$DB_HOST:$DB_PORT ubuntu@$JUMPBOX_IP -i $KEYFILE
trap cleanup EXIT

sql() {
    PGPASSWORD=$DB_PASS psql -h localhost -p $LOCAL_PORT -U $DB_USER -d paastest -c "$*"
}

exists() {
    PGPASSWORD=$DB_PASS psql -h localhost -p $LOCAL_PORT -U $DB_USER -d paastest -l | grep -q $1
}

create() {
    exists $1 || { echo "create database $1"; sql "create database $1"; }
}

create bosh
create uaa
create credhub
