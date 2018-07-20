#!/bin/bash

set -euo pipefail

bosh_admin_password=$(bosh int bosh-vars-s3/bosh-variables.yml --path /admin_password)
bosh int bosh-vars-s3/bosh-variables.yml --path /default_ca/ca > bosh_ca.pem
bosh_ip=$(bosh int --path '/cloud_provider/ssh_tunnel/host' bosh-manifest-s3/bosh.yml)

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="${bosh_admin_password}"
export BOSH_ENVIRONMENT="https://${bosh_ip}:25555"
export BOSH_CA_CERT=$(cat bosh_ca.pem)

#TODO Needs to be parameterised
bosh upload-release https://github.com/bosh-prometheus/node-exporter-boshrelease/releases/download/v4.0.0/node-exporter-4.0.0.tgz

cat > node-exporter-config.yml <<EOF
releases:
  - name: node-exporter
    version: 4.0.0

addons:
  - name: node_exporter
    jobs:
      - name: node_exporter
        release: node-exporter
    include:
      stemcell:
        - os: ubuntu-trusty
    properties: {}
EOF

bosh update-runtime-config --non-interactive node-exporter-config.yml
