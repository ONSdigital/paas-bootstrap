#!/bin/bash

set -euo pipefail

cp bosh-vars-s3/bosh-variables.yml bosh-manifests/bosh-variables.yml

jq '.modules[0].outputs | with_entries(.value = .value.value)' < "bosh-tfstate-s3/${ENVIRONMENT}.tfstate" > bosh-vars.json

bosh int \
  ./bosh-deployment-git/bosh.yml \
  --vars-store bosh-manifests/bosh-variables.yml \
  -o bosh-deployment-git/aws/cpi.yml \
  -o bosh-deployment-git/aws/cli-iam-instance-profile.yml \
  -o paas-bootstrap-git/operations/bosh/tags.yml \
  -v director_name=bosh \
  -v internal_cidr="$(jq -r .internal_cidr < bosh-vars.json)" \
  -v internal_gw="$(jq -r .internal_cidr < bosh-vars.json | sed 's#0/24#1#')" \
  -v internal_ip="$(jq -r .internal_cidr < bosh-vars.json | sed 's#0/24#6#')" \
  -v region="$(jq -r .region < bosh-vars.json)" \
  -v az="$(jq -r .az < bosh-vars.json)" \
  -v default_key_name="$(jq -r .default_key_name < bosh-vars.json)" \
  -v default_security_groups="[$(jq -r .bosh_security_group < bosh-terraform/metadata)]" \
  --var-file private_key=ssh-private-key-s3/ssh-key.pem \
  -v subnet_id="$(jq -r .subnet_id < bosh-vars.json)" \
  -v environment="${ENVIRONMENT}" \
  > bosh-manifests/bosh.yml
