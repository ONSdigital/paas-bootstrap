#!/bin/bash

set -euo pipefail

cp cf-vars-s3/cf-variables.yml cf-manifests/cf-variables.yml

SYSTEM_DOMAIN="system.${DOMAIN}"
APPS_DOMAIN="apps.${DOMAIN}" 


bosh int \
  ./cf-deployment-git/cf-deployment.yml \
  --vars-store cf-manifests/cf-variables.yml \
  -o cf-deployment-git/operations/aws.yml \
  -o cf-deployment-git/operations/scale-to-one-az.yml \
  -o cf-deployment-git/operations/override-app-domains.yml \
  -o paas-bootstrap-git/operations/cf/stemcells.yml \
  -o paas-bootstrap-git/operations/cf/router-sec-group.yml \
  -o paas-bootstrap-git/operations/cf/scheduler-instance-type.yml \
  -v system_domain="${SYSTEM_DOMAIN}" \
  -v app_domains="[${APPS_DOMAIN}]" \
  -v smoke_test_app_domain="${APPS_DOMAIN}" \
  > cf-manifests/cf.yml
