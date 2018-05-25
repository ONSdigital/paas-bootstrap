#!/bin/bash

set -euo pipefail

jq '.modules[0].outputs | with_entries(.value = .value.value)' < vpc-tfstate-s3/tfstate.json > vpc-vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < cf-tfstate-s3/tfstate.json > cf-vars.json

bosh update-cloud-config \
  ./cf-deployment-git/cf-deployment.yml \
  -v az1="$(jq -r .az1 < vpc-vars.json)" \
  -v private_subnet_gateway="$(jq -r .internal_cidr < cf-vars.json | sed 's#0/24#1#')" \
  -v internal_security_group="$(jq -r .cf-internal-security-group-id < cf-vars.json)" \
  -v private_subnet_id="$(jq -r .cf-internal-subnet-az1-id < cf-vars.json)" \
  -v private_subnet_cidr="$(jq -r .cf-internal-subnet-az1-cidr < cf-vars.json)" \
  paas-bootstrap-git/cloud-config/cf/cloud-config.yml

bosh cloud-config > cf-manifests/cloud-config.yml
