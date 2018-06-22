#!/bin/bash

set -euo pipefail

cp cf-vars-s3/cf-variables.yml cf-manifests/cf-variables.yml
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "cf-tfstate-s3/${ENVIRONMENT}.tfstate" > cf-vars.json

SYSTEM_DOMAIN="system.${DOMAIN}"
APPS_DOMAIN="apps.${DOMAIN}" 

bosh int \
  ./cf-deployment-git/cf-deployment.yml \
  --vars-store cf-manifests/cf-variables.yml \
  -o cf-deployment-git/operations/aws.yml \
  -o cf-deployment-git/operations/scale-to-one-az.yml \
  -o cf-deployment-git/operations/override-app-domains.yml \
  -o cf-deployment-git/operations/use-external-blobstore.yml \
  -o paas-bootstrap-git/operations/cf/stemcells.yml \
  -o paas-bootstrap-git/operations/cf/router-sec-group.yml \
  -o paas-bootstrap-git/operations/cf/scheduler-instance-type.yml \
  -o paas-bootstrap-git/operations/cf/s3_blobstore_with_kms_and_iam.yml \
  -v system_domain="${SYSTEM_DOMAIN}" \
  -v app_domains="[${APPS_DOMAIN}]" \
  -v smoke_test_app_domain="${APPS_DOMAIN}" \
  -v buildpack_directory_key="$(jq -r '.cf_buildpacks_bucket_name' < cf-vars.json)" \
  -v droplet_directory_key="$(jq -r '.cf_droplets_bucket_name' < cf-vars.json)" \
  -v app_package_directory_key="$(jq -r '.cf_packages_bucket_name' < cf-vars.json)" \
  -v resource_directory_key="$(jq -r '.cf_resource_pool_bucket_name' < cf-vars.json)" \
  -v cf_blobstore_s3_kms_key_id="$(jq -r '.cf_blobstore_s3_kms_key_id' < cf-vars.json)" \
  > cf-manifests/cf.yml
