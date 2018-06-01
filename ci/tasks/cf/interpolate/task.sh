#!/bin/bash

set -euo pipefail

cp cf-vars-s3/cf-variables.yml cf-manifests/cf-variables.yml

SYSTEM_DOMAIN="system.${DOMAIN}"

bosh int \
  ./cf-deployment-git/cf-deployment.yml \
  --vars-store cf-manifests/cf-variables.yml \
  -o cf-deployment-git/operations/aws.yml \
  -o cf-deployment-git/operations/scale-to-one-az.yml \
  -o paas-bootstrap-git/operations/cf/stemcells.yml \
  -o paas-bootstrap-git/operations/cf/router-sec-group.yml \
  -o paas-bootstrap-git/operations/cf/router-extensions.yml \
  -v system_domain="${SYSTEM_DOMAIN}" \
  -v cf-router-target-group-name="$(jq -r '."cf-router-target-group-name"' < cf-vars/vars.json)" \
  -v cf-router-lb-internal-security-group-id="$(jq -r '."cf-router-lb-internal-security-group-id"' < cf-vars/vars.json)" \
  -v cf-internal-security-group-id="$(jq -r '."cf-internal-security-group-id"' < cf-vars/vars.json)" \
  > cf-manifests/cf.yml
