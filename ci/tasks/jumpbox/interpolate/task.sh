#!/bin/bash

set -euo pipefail

cp jumpbox-vars-s3/jumpbox-variables.yml jumpbox-manifests/jumpbox-variables.yml

cat concourse-tfstate-s3/tfstate.json | jq '.modules[0].outputs | with_entries(.value = .value.value)' > concourse-vars.json

bosh int \
  ./jumpbox-deployment-git/jumpbox.yml \
  --vars-store jumpbox-manifests/jumpbox-variables.yml \
  -v internal_cidr="$(jq -r .internal_cidr < concourse-vars.json)" \
  -v internal_ip="$(jq -r .internal_cidr < concourse-vars.json | sed 's#0/24#5#')" \
  -v internal_gw="$(jq -r .internal_cidr < concourse-vars.json | sed 's#0/24#1#')" \
  -v default_security_groups="[$(jq -r .jumpbox_security_group < jumpbox-terraform/metadata)]" \
  -v external_ip="$(jq -r .jumpbox_external_ip < jumpbox-terraform/metadata)" \
  -v region="$(jq -r .region < concourse-vars.json)" \
  -v az="$(jq -r .az < concourse-vars.json)" \
  -v subnet_id="$(jq -r .subnet_id < concourse-vars.json)" \
  -v default_key_name="$(jq -r .default_key_name < concourse-vars.json)" \
  -v environment="${ENVIRONMENT}" \
  --var-file private_key=ssh-private-key-s3/ssh-key.pem \
  -o ./paas-bootstrap-git/operations/jumpbox/aws_cpi.yml \
  -o ./paas-bootstrap-git/operations/jumpbox/tags.yml > jumpbox-manifests/jumpbox.yml
