#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

output() {
    FILE=$1
    QUERY=$2

    FILE="${FILE}-tfstate-s3/${ENVIRONMENT}-${FILE}.tfstate"
    jq -r ".modules[0].outputs | with_entries(.value = .value.value) | $QUERY" <"$FILE"
}

DOMAIN="$(output base .domain)"
SYSTEM_DOMAIN="system.${DOMAIN}"
APPS_DOMAIN="apps.${DOMAIN}"

CF_DB_ENDPOINT="$(output rds .cf_rds_fqdn)"
CF_DB_USERNAME="$(output rds .cf_db_username)"
CF_DB_PASSWORD="$(output rds .cf_rds_password)"

profile="${ENVIRONMENT}"
[ -d "paas-bootstrap-git/profiles/${ENVIRONMENT}" ] || profile="engineering"

instance_count_file=paas-bootstrap-git/profiles/${profile}/instance-count.yml

echo "Constructing variables"
cp "${instance_count_file}" vars-files/instance-counts.yml

cat >vars-files/variables.yml <<-EOS
environment: ${ENVIRONMENT}
region: $(jq -r .region < states-variables-s3/$ENVIRONMENT.tfvars)
system_domain: ${SYSTEM_DOMAIN}
app_domains: [${APPS_DOMAIN}]
smoke_test_app_domain: ${APPS_DOMAIN}
buildpack_directory_key: $(output base .cf_buildpacks_bucket_name)
droplet_directory_key: $(output base .cf_droplets_bucket_name)
app_package_directory_key: $(output base .cf_packages_bucket_name)
resource_directory_key: $(output base .cf_resource_pool_bucket_name)
cf_blobstore_s3_kms_key_id: $(output base .cf_blobstore_s3_kms_key_id)
external_database_type: $(output rds .cf_db_type)
external_database_port: $(output rds .cf_db_port)
external_uaa_database_name: uaa
external_uaa_database_address: ${CF_DB_ENDPOINT}
external_uaa_database_password: ${CF_DB_PASSWORD}
external_uaa_database_username: ${CF_DB_USERNAME}
external_cc_database_name: cc
external_cc_database_address: ${CF_DB_ENDPOINT}
external_cc_database_password: ${CF_DB_PASSWORD}
external_cc_database_username: ${CF_DB_USERNAME}
external_bbs_database_name: bbs
external_bbs_database_address: ${CF_DB_ENDPOINT}
external_bbs_database_password: ${CF_DB_PASSWORD}
external_bbs_database_username: ${CF_DB_USERNAME}
external_routing_api_database_name: routing_api
external_routing_api_database_address: ${CF_DB_ENDPOINT}
external_routing_api_database_password: ${CF_DB_PASSWORD}
external_routing_api_database_username: ${CF_DB_USERNAME}
external_policy_server_database_name: policy_server
external_policy_server_database_address: ${CF_DB_ENDPOINT}
external_policy_server_database_password: ${CF_DB_PASSWORD}
external_policy_server_database_username: ${CF_DB_USERNAME}
external_silk_controller_database_name: silk_controller
external_silk_controller_database_address: ${CF_DB_ENDPOINT}
external_silk_controller_database_password: ${CF_DB_PASSWORD}
external_silk_controller_database_username: ${CF_DB_USERNAME}
external_locket_database_name: locket
external_locket_database_address: ${CF_DB_ENDPOINT}
external_locket_database_password: ${CF_DB_PASSWORD}
external_locket_database_username: ${CF_DB_USERNAME}
external_credhub_database_name: credhub
external_credhub_database_address: ${CF_DB_ENDPOINT}
external_credhub_database_password: ${CF_DB_PASSWORD}
external_credhub_database_username: ${CF_DB_USERNAME}
EOS

echo "Deploying"

export BOSH_ENVIRONMENT=$(output base .bosh_private_ip)

bosh deploy -n -d cf cf-deployment-git/cf-deployment.yml \
  -o cf-deployment-git/operations/aws.yml \
  -o cf-deployment-git/operations/override-app-domains.yml \
  -o cf-deployment-git/operations/use-external-blobstore.yml \
  -o cf-deployment-git/operations/use-external-dbs.yml \
  -o prometheus-boshrelease-git/manifests/operators/cf/add-prometheus-uaa-clients.yml \
  -o paas-bootstrap-git/operations/bosh/tags.yml \
  -o paas-bootstrap-git/operations/cf/router-sec-group.yml \
  -o paas-bootstrap-git/operations/cf/scheduler.yml \
  -o paas-bootstrap-git/operations/cf/s3_blobstore_with_kms_and_iam.yml \
  -o paas-bootstrap-git/operations/cf/azs.yml \
  -o paas-bootstrap-git/operations/cf/instance-counts.yml \
  -o paas-bootstrap-git/operations/cf/rds-access.yml \
  -o paas-bootstrap-git/operations/cf/uaa-clients.yml \
  -o paas-bootstrap-git/operations/cf/test-user.yml \
  -o paas-bootstrap-git/operations/cf/api-workers.yml \
  -l vars-files/instance-counts.yml \
  -l vars-files/variables.yml