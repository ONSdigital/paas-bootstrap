#!/bin/bash

set -euo pipefail

jq '.modules[0].outputs | with_entries(.value = .value.value)' < vpc-tfstate-s3/tfstate.json > vpc-vars/vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "cf-tfstate-s3/${ENVIRONMENT}.tfstate" > cf-vars/vars.json

cat >cf-vars/env <<-EOS
USER_DB=$(jq -r .cf_db_username < cf-vars/vars.json)
DUMMY_DB=$(jq -r .cf_dummy_db < cf-vars/vars.json)
PASSWORD_DB=$(jq -r .cf_rds_password < cf-vars/vars.json)
FQDN_DB=$(jq -r .cf_rds_fqdn < cf-vars/vars.json)
EOS