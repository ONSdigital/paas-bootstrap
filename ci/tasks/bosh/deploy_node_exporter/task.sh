#!/bin/bash

set -euo pipefail

bosh_ip=$(bosh int --path '/cloud_provider/ssh_tunnel/host' bosh-manifest-s3/bosh.yml)

export BOSH_ENVIRONMENT="https://${bosh_ip}:25555"

bosh upload-release https://github.com/bosh-prometheus/node-exporter-boshrelease/releases/download/v4.0.0/node-exporter-4.0.0.tgz