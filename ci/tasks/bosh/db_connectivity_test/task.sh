#!/bin/bash

set -euo pipefail

set -a
source bosh-vars/env
set +a

: $USER_DB
: $FQDN_DB
: $PASSWORD_DB

# psql postgresql://user:pass@host:5432/{$}
pg_isready -h ${FQDN_DB} -U ${USER_DB} 