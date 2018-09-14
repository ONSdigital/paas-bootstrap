#!/bin/bash

set -euo pipefail

while getopts 'e:' option; do
  case $option in
    e) export ENVIRONMENT="$OPTARG";;
  esac
done

shift $((OPTIND-1))

: $ENVIRONMENT

BOSH_DB_USER=$(bin/outputs.sh rds | jq -r .bosh_db_username)
BOSH_DB_HOST=$(bin/outputs.sh rds | jq -r .bosh_db_host)
BOSH_DB_PORT=$(bin/outputs.sh rds | jq -r .bosh_db_port)
BOSH_DB_PASS=$(bin/outputs.sh rds | jq -r .bosh_rds_password)

CF_DB_USER=$(bin/outputs.sh rds | jq -r .cf_db_username)
CF_DB_HOST=$(bin/outputs.sh rds | jq -r .cf_db_host)
CF_DB_PORT=$(bin/outputs.sh rds | jq -r .cf_db_port)
CF_DB_PASS=$(bin/outputs.sh rds | jq -r .cf_rds_password)


JUMPBOX_IP=$(bin/outputs.sh | jq -r .jumpbox_public_ip)
KEYFILE=~/.ssh/$ENVIRONMENT.jumpbox.$$.pem
bin/outputs.sh | jq -r .jumpbox_private_key >$KEYFILE
chmod 600 $KEYFILE

BOSH_LOCAL_PORT=30201
CF_LOCAL_PORT=30202

cleanup() {
    rm -f $KEYFILE
    kill $(ps -ef | awk "/ssh.*$BOSH_LOCAL_PORT/ && ! /awk/ { print \$2 }")
    kill $(ps -ef | awk "/ssh.*$CF_LOCAL_PORT/ && ! /awk/ { print \$2 }")
}

ssh -fN -L $BOSH_LOCAL_PORT:$BOSH_DB_HOST:$BOSH_DB_PORT ubuntu@$JUMPBOX_IP -i $KEYFILE
ssh -fN -L $CF_LOCAL_PORT:$CF_DB_HOST:$CF_DB_PORT ubuntu@$JUMPBOX_IP -i $KEYFILE

trap cleanup EXIT

sql() {
    PGPASSWORD=$BOSH_DB_PASS psql -h localhost -p $BOSH_LOCAL_PORT -U $BOSH_DB_USER -d paastest -c "$*"
}

destroy_bosh() {
    sql "drop database $1"
}

destroy_cf() {
    echo "drop database if exists $1" | MYSQL_PWD=$CF_DB_PASS mysql --protocol=tcp -h localhost -P $CF_LOCAL_PORT -u $CF_DB_USER
}

case "$1" in
cf)
    echo "Destroy CF db"
    destroy_cf $2
    ;;
bosh)
    echo "Destroy Bosh db"
    destroy_bosh $2
    ;;
esac