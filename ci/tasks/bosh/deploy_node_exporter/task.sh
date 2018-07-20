#!/bin/bash

set -euo pipefail

bosh_admin_password=$(bosh int bosh-vars-s3/bosh-variables.yml --path /admin_password)
bosh int bosh-vars-s3/bosh-variables.yml --path /default_ca/ca > bosh_ca.pem
bosh_ip=$(bosh int --path '/cloud_provider/ssh_tunnel/host' bosh-manifest-s3/bosh.yml)

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="${bosh_admin_password}"
export BOSH_ENVIRONMENT="https://${bosh_ip}:25555"
export BOSH_CA_CERT=$(cat bosh_ca.pem)

RUNTIME_CONFIG=paas-bootstrap-git/runtime-config/bosh/node-exporter-config.yml

#TODO Needs to be parameterised
bosh upload-release https://github.com/bosh-prometheus/node-exporter-boshrelease/releases/download/v${NODE_EXPORTER_VERSION}/node-exporter-${NODE_EXPORTER_VERSION}.tgz

bosh update-runtime-config --non-interactive ${RUNTIME_CONFIG}
