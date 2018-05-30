#!/bin/bash

set -euo pipefail

bosh_admin_password=$(bosh int bosh-vars-s3/bosh-variables.yml --path /admin_password)
bosh int bosh-vars-s3/bosh-variables.yml --path /default_ca/ca > bosh_ca.pem
bosh_ip=$(bosh int --path '/cloud_provider/ssh_tunnel/host' bosh-manifest-s3/bosh.yml)

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="${bosh_admin_password}"
export BOSH_ENVIRONMENT="https://${bosh_ip}:25555"
export BOSH_CA_CERT=$(cat bosh_ca.pem)

export STEMCELL_VERSION=$(bosh int cf-deployment-git/cf-deployment.yml --path /stemcells/alias=default/version)
bosh upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=$STEMCELL_VERSION

export BOSH_LOG_LEVEL=info
bosh -d cf --non-interactive deploy ./cf-manifest-s3/cf.yml
