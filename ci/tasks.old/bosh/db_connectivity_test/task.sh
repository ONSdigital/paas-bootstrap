#!/bin/bash

set -euo pipefail

set -a
source bosh-vars/env
set +a

: $USER_DB
: $FQDN_DB
: $PASSWORD_DB
: $DUMMY_DB

pg_isready -h ${FQDN_DB} -U ${USER_DB} 

set +e
while :
do
  PGPASSWORD=$PASSWORD_DB psql -c "select 1" -h $FQDN_DB -U $USER_DB -d $DUMMY_DB && break
done