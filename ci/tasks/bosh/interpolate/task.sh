#!/bin/bash

set -euo pipefail

cp bosh-vars-s3/bosh-variables.yml bosh-manifests/bosh-variables.yml

jq '.modules[0].outputs | with_entries(.value = .value.value)' < concourse-tfstate-s3/tfstate.json > concourse-vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "bosh-tfstate-s3/${ENVIRONMENT}.tfstate" > bosh-vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "bosh-databases-tfstate-s3/${ENVIRONMENT}.tfstate" > databases-vars.json


bosh int \
  ./bosh-deployment-git/bosh.yml \
  --vars-store bosh-manifests/bosh-variables.yml \
  -o bosh-deployment-git/aws/cpi.yml \
  -o bosh-deployment-git/aws/cli-iam-instance-profile.yml \
  -o bosh-deployment-git/misc/external-db.yml \
  -o paas-bootstrap-git/operations/bosh/iam-instance-profile.yml \
  -o paas-bootstrap-git/operations/bosh/tags.yml \
  -v director_name=bosh \
  -v internal_cidr="$(jq -r .internal_cidr < bosh-vars.json)" \
  -v internal_gw="$(jq -r .internal_cidr < bosh-vars.json | sed 's#0/24#1#')" \
  -v internal_ip="$(jq -r .internal_cidr < bosh-vars.json | sed 's#0/24#6#')" \
  -v region="$(jq -r .region < bosh-vars.json)" \
  -v bosh_iam_instance_profile="$(jq -r .bosh_iam_instance_profile < bosh-vars.json)" \
  -v az="$(jq -r .az < bosh-vars.json)" \
  -v default_key_name="$(jq -r .default_key_name < concourse-vars.json)" \
  -v default_security_groups="$(jq -r .default_security_groups < bosh-terraform/metadata)" \
  --var-file private_key=ssh-private-key-s3/ssh-key.pem \
  -v subnet_id="$(jq -r .subnet_id < bosh-vars.json)" \
  -v environment="${ENVIRONMENT}" \
  -v external_db_host="$(jq -r '.bosh_rds_fqdn' < bosh-vars.json)" \
  -v external_db_port="$(jq -r '.bosh_db_port' < bosh-vars.json)" \
  -v external_db_user="$(jq -r '.bosh_db_username' < bosh-vars.json)" \
  -v external_db_password="$(jq -r '.bosh_rds_password' < bosh-vars.json)" \
  -v external_db_adapter="$(jq -r '.bosh_db_type' < bosh-vars.json)" \
  -v external_db_name="$(jq -r '.bosh_database_name' < databases-vars.json)" \
  > bosh-manifests/bosh.yml
