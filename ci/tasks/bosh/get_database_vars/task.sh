#!/bin/bash

set -euo pipefail

jq '.modules[0].outputs | with_entries(.value = .value.value)' < vpc-tfstate-s3/tfstate.json > vpc-vars/vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "bosh-terraform/terraform.tfstate" > bosh-vars/vars.json

cat >bosh-vars/env <<-EOS
USER_DB=$(jq -r .bosh_db_username < bosh-vars/vars.json)
DUMMY_DB=$(jq -r .bosh_dummy_db < bosh-vars/vars.json)
PASSWORD_DB=$(jq -r .bosh_rds_password < bosh-vars/vars.json)
FQDN_DB=$(jq -r .bosh_rds_fqdn < bosh-vars/vars.json)
EOS
