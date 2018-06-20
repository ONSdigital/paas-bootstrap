#!/bin/bash

set -euo pipefail

bosh_admin_password=$(bosh int bosh-vars-s3/bosh-variables.yml --path /admin_password)
bosh int bosh-vars-s3/bosh-variables.yml --path /default_ca/ca > bosh_ca.pem
bosh_ip=$(bosh int --path '/cloud_provider/ssh_tunnel/host' bosh-manifest-s3/bosh.yml)

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="${bosh_admin_password}"
export BOSH_ENVIRONMENT="https://${bosh_ip}:25555"
export BOSH_CA_CERT=$(cat bosh_ca.pem)

jq '.modules[0].outputs | with_entries(.value = .value.value)' < vpc-tfstate-s3/tfstate.json > vpc-vars/vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < concourse-tfstate-s3/tfstate.json > concourse-vars/vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "bosh-tfstate-s3/${ENVIRONMENT}.tfstate" > bosh-vars/vars.json

bosh -d cf --non-interactive delete-deployment