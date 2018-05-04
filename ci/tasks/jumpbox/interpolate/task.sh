#!/bin/bash

set -euo pipefail

cp jumpbox-vars-s3/jumpbox-variables.yml jumpbox-manifests/jumpbox-variables.yml

cat vpc-tfstate-s3/tfstate.json | jq '.modules[0].outputs | with_entries(.value = .value.value)' > concourse-vars/vars.json

jq -r .internal_cidr < concourse-vars/vars.json

# bosh int \
#   ./jumpbox-deployment-git/jumpbox.yml \
#   --vars-store jumpbox-manifests/jumpbox-variables.yml \
#   -v internal_cidr="$(jq -r .internal_cidr < terraform/metadata)" \
#   -v internal_ip="$(jq -r .internal_cidr < terraform/metadata | sed 's#0/24#5#')" \
#   -v internal_gw="$(jq -r .internal_cidr < terraform/metadata | sed 's#0/24#1#')" \
#   -v default_security_groups="[$(jq -r .jumpbox_security_group < terraform/metadata)]" \
#   -v external_ip="$(jq -r .external_ip < terraform/metadata)" \
#   -v region="eu-west-1" \
#   -v az="$(jq -r .bosh_subnet_availability_zone < terraform/metadata)" \
#   -v subnet_id="$(jq -r .bosh_subnet_id < terraform/metadata)" \
#   -v default_key_name="$(jq -r .bosh_vms_key_name < terraform/metadata)" \
#   -v iam_instance_profile="$(jq -r .bosh_iam_instance_profile < terraform/metadata)" \
#   --var-file private_key=ssh-private-key-s3/ssh-key.pem \
#   -o ./cf-demo-git/ops-files/jumpbox-aws-cpi.yml > jumpbox-manifests/jumpbox.yml
