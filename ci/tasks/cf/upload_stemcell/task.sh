#!/bin/bash

set -euo pipefail

bosh_admin_password=$(bosh int bosh-vars-s3/bosh-variables.yml --path /admin_password)
bosh int bosh-vars-s3/bosh-variables.yml --path /default_ca/ca > bosh_ca.pem
bosh_ip=$(bosh int --path '/cloud_provider/ssh_tunnel/host' bosh-manifest-s3/bosh.yml)
stemcell_version=$(bosh int cf-manifest-s3/cf.yml --path=/stemcells/alias=default/version)

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="${bosh_admin_password}"
export BOSH_ENVIRONMENT="https://${bosh_ip}:25555"
export BOSH_CA_CERT=$(cat bosh_ca.pem)

# Upload the stemcell only if it doesn't already exist
if ! bosh -n stemcells | grep -q "$stemcell_version"; then
  bosh upload-stemcell https://s3.amazonaws.com/bosh-aws-light-stemcells/light-bosh-stemcell-${stemcell_version}-aws-xen-hvm-ubuntu-trusty-go_agent.tgz
fi
