#!/bin/bash

set -euo pipefail

jq '.modules[0].outputs | with_entries(.value = .value.value)' < vpc-tfstate-s3/tfstate.json > vpc-vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "cf-tfstate-s3/${ENVIRONMENT}.tfstate" > cf-vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < concourse-tfstate-s3/tfstate.json > concourse-vars.json

bosh_admin_password=$(bosh int bosh-vars-s3/bosh-variables.yml --path /admin_password)
bosh int bosh-vars-s3/bosh-variables.yml --path /default_ca/ca > bosh_ca.pem
bosh_ip=$(bosh int --path '/cloud_provider/ssh_tunnel/host' bosh-manifest-s3/bosh.yml)

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="${bosh_admin_password}"
export BOSH_ENVIRONMENT="https://${bosh_ip}:25555"
export BOSH_CA_CERT=bosh_ca.pem

bosh update-cloud-config -n \
  paas-bootstrap-git/cloud-config/cf/cloud-config.yml \
  -v az1="$(jq -r .az1 < vpc-vars.json)" \
  -v private_subnet_gateway="$(jq -r '."nat_id"' < concourse-vars.json | sed 's#0/24#1#')" \
  -v internal_security_group="$(jq -r '."cf-internal-security-group-id"' < cf-vars.json)" \
  -v private_subnet_id="$(jq -r '."cf-internal-subnet-az1-id"' < cf-vars.json)" \
  -v private_subnet_cidr="$(jq -r '."cf-internal-subnet-az1-cidr"' < cf-vars.json)"

bosh cloud-config > cf-manifests/cloud-config.yml
