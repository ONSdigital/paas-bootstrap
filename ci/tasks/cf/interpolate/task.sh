#!/bin/bash

set -euo pipefail

cp cf-vars-s3/cf-variables.yml cf-manifests/cf-variables.yml
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "cf-tfstate-s3/${ENVIRONMENT}.tfstate" > cf-vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < vpc-tfstate-s3/tfstate.json > vpc-vars.json
jq '.modules[0].outputs | with_entries(.value = .value.value)' < "databases-tfstate-s3/${ENVIRONMENT}.tfstate" > databases-vars.json


SYSTEM_DOMAIN="system.${DOMAIN}"
APPS_DOMAIN="apps.${DOMAIN}"

CF_DB_ENDPOINT="$(jq -r '.cf_rds_fqdn' < cf-vars.json)"
CF_DB_USERNAME="$(jq -r '.cf_db_username' < cf-vars.json)"
CF_DB_PASSWORD="$(jq -r '.cf_rds_password' < cf-vars.json)"

if [[ ${ENVIRONMENT} = "eng"* ]]; then
  profile="engineering"
else
  profile="${ENVIRONMENT}"
fi
instance_count_file=paas-bootstrap-git/profiles/${profile}/instance-count.yml

bosh int \
  ./cf-deployment-git/cf-deployment.yml \
  --vars-store cf-manifests/cf-variables.yml \
  --vars-file="${instance_count_file}" \
  -o cf-deployment-git/operations/aws.yml \
  -o cf-deployment-git/operations/override-app-domains.yml \
  -o cf-deployment-git/operations/use-external-blobstore.yml \
  -o cf-deployment-git/operations/use-external-dbs.yml \
  -o prometheus-boshrelease-git/manifests/operators/cf/add-prometheus-uaa-clients.yml \
  -o paas-bootstrap-git/operations/bosh/tags.yml \
  -o paas-bootstrap-git/operations/cf/stemcells.yml \
  -o paas-bootstrap-git/operations/cf/router-sec-group.yml \
  -o paas-bootstrap-git/operations/cf/scheduler.yml \
  -o paas-bootstrap-git/operations/cf/s3_blobstore_with_kms_and_iam.yml \
  -o paas-bootstrap-git/operations/cf/azs.yml \
  -o paas-bootstrap-git/operations/cf/instance-counts.yml \
  -o paas-bootstrap-git/operations/cf/rds-access.yml \
  -v environment="${ENVIRONMENT}" \
  -v region="$(jq -r .region < vpc-vars.json)" \
  -v system_domain="${SYSTEM_DOMAIN}" \
  -v app_domains="[${APPS_DOMAIN}]" \
  -v smoke_test_app_domain="${APPS_DOMAIN}" \
  -v buildpack_directory_key="$(jq -r '.cf_buildpacks_bucket_name' < cf-vars.json)" \
  -v droplet_directory_key="$(jq -r '.cf_droplets_bucket_name' < cf-vars.json)" \
  -v app_package_directory_key="$(jq -r '.cf_packages_bucket_name' < cf-vars.json)" \
  -v resource_directory_key="$(jq -r '.cf_resource_pool_bucket_name' < cf-vars.json)" \
  -v cf_blobstore_s3_kms_key_id="$(jq -r '.cf_blobstore_s3_kms_key_id' < cf-vars.json)" \
  -v external_database_type="$(jq -r '.cf_db_type' < cf-vars.json)" \
  -v external_database_port="$(jq -r '.cf_db_port' < cf-vars.json)" \
  -v external_uaa_database_name="$(jq -r '.uaa_database_name' < databases-vars.json)" \
  -v external_uaa_database_address="${CF_DB_ENDPOINT}" \
  -v external_uaa_database_password="${CF_DB_PASSWORD}" \
  -v external_uaa_database_username="${CF_DB_USERNAME}" \
  -v external_cc_database_name="$(jq -r '.cc_database_name' < databases-vars.json)" \
  -v external_cc_database_address="${CF_DB_ENDPOINT}" \
  -v external_cc_database_password="${CF_DB_PASSWORD}" \
  -v external_cc_database_username="${CF_DB_USERNAME}" \
  -v external_bbs_database_name="$(jq -r '.bbs_database_name' < databases-vars.json)" \
  -v external_bbs_database_address="${CF_DB_ENDPOINT}" \
  -v external_bbs_database_password="${CF_DB_PASSWORD}" \
  -v external_bbs_database_username="${CF_DB_USERNAME}" \
  -v external_routing_api_database_name="$(jq -r '.routing_api_database_name' < databases-vars.json)" \
  -v external_routing_api_database_address="${CF_DB_ENDPOINT}" \
  -v external_routing_api_database_password="${CF_DB_PASSWORD}" \
  -v external_routing_api_database_username="${CF_DB_USERNAME}" \
  -v external_policy_server_database_name="$(jq -r '.policy_server_database_name' < databases-vars.json)" \
  -v external_policy_server_database_address="${CF_DB_ENDPOINT}" \
  -v external_policy_server_database_password="${CF_DB_PASSWORD}" \
  -v external_policy_server_database_username="${CF_DB_USERNAME}" \
  -v external_silk_controller_database_name="$(jq -r '.silk_controller_database_name' < databases-vars.json)" \
  -v external_silk_controller_database_address="${CF_DB_ENDPOINT}" \
  -v external_silk_controller_database_password="${CF_DB_PASSWORD}" \
  -v external_silk_controller_database_username="${CF_DB_USERNAME}" \
  -v external_locket_database_name="$(jq -r '.locket_database_name' < databases-vars.json)" \
  -v external_locket_database_address="${CF_DB_ENDPOINT}" \
  -v external_locket_database_password="${CF_DB_PASSWORD}" \
  -v external_locket_database_username="${CF_DB_USERNAME}" \
    > cf-manifests/cf.yml
