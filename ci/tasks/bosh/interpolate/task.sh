#!/bin/bash

set -euo pipefail

cp bosh-vars-s3/bosh-variables.yml bosh-manifests/bosh-variables.yml

cat concourse-tfstate-s3/tfstate.json | jq '.modules[0].outputs | with_entries(.value = .value.value)' > concourse-vars.json

bosh int \
  ./bosh-deployment-git/bosh.yml \
  --vars-store bosh-manifests/bosh-variables.yml \
  -v director_name=bosh \
  -v internal_cidr="$(jq -r .internal_cidr < concourse-vars.json)" \
  -v internal_gw="$(jq -r .internal_cidr < concourse-vars.json | sed 's#0/24#1#')" \
  -v internal_ip="$(jq -r .internal_cidr < concourse-vars.json | sed 's#0/24#6#')" \
  -v region="$(jq -r .region < concourse-vars.json)" \
  -v az="$(jq -r .az < concourse-vars.json)" \
  -v default_key_name="$(jq -r .default_key_name < concourse-vars.json)" \
  -v default_security_groups="[$(jq -r .bosh_security_group < bosh-terraform/metadata)]" \
  --var-file private_key=ssh-private-key-s3/ssh-key.pem \
  -v subnet_id="$(jq -r .subnet_id < concourse-vars.json)" \

  -v environment="${ENVIRONMENT}" \
  -o IAM_OPS_FILE_HERE

  -v external_ip="$(jq -r .bosh_external_ip < bosh-terraform/metadata)" \



  -o ./paas-bootstrap-git/operations/bosh/aws_cpi.yml \
  -o ./paas-bootstrap-git/operations/bosh/tags.yml > bosh-manifests/bosh.yml
