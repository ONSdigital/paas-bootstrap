#!/bin/bash

set -euo pipefail

set -a
source cf-vars/env
set +a

: $USER_DB
: $FQDN_DB
: $PASSWORD_DB
: $DUMMY_DB


set +e
while :
do
  mysql -u$USER_DB -p$PASSWORD_DB -h $FQDN_DB $DUMMY_DB <<<"select 1;" && break
  sleep 1
done