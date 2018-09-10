#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

output() {
    FILE=$1
    QUERY=$2

    bin/outputs.sh $FILE | jq -r "$QUERY"
}

bin/get_states.sh -e $ENVIRONMENT

BOSH="bin/bosh_credentials.sh -e $ENVIRONMENT bosh"

DOMAIN="$(output base .domain)"
SYSTEM_DOMAIN="system.${DOMAIN}"
APPS_DOMAIN="apps.${DOMAIN}"

CF_DB_ENDPOINT="$(output rds .cf_rds_fqdn)"
CF_DB_USERNAME="$(output rds .cf_db_username)"
CF_DB_PASSWORD="$(output rds .cf_rds_password)"

profile="${ENVIRONMENT}"
[ -d "profiles/${ENVIRONMENT}" ] || profile="engineering"

instance_count_file=./profiles/${profile}/instance-count.yml

echo "Deploying"
$BOSH deploy -n -d cf \
  ./cf-deployment/cf-deployment.yml \
  --vars-file="${instance_count_file}" \
  -o cf-deployment/operations/aws.yml \
  -o cf-deployment/operations/override-app-domains.yml \
  -o cf-deployment/operations/use-external-blobstore.yml \
  -o cf-deployment/operations/use-external-dbs.yml \
  -o prometheus-boshrelease/manifests/operators/cf/add-prometheus-uaa-clients.yml \
  -o ./operations/bosh/tags.yml \
  -o ./operations/cf/router-sec-group.yml \
  -o ./operations/cf/scheduler.yml \
  -o ./operations/cf/s3_blobstore_with_kms_and_iam.yml \
  -o ./operations/cf/azs.yml \
  -o ./operations/cf/instance-counts.yml \
  -o ./operations/cf/rds-access.yml \
  -o ./operations/cf/uaa-clients.yml \
  -o ./operations/cf/test-user.yml \
  -o ./operations/cf/api-workers.yml \
  -v environment="${ENVIRONMENT}" \
  -v region="$(jq -r .region < data/$ENVIRONMENT.tfvars)" \
  -v system_domain="${SYSTEM_DOMAIN}" \
  -v app_domains="[${APPS_DOMAIN}]" \
  -v smoke_test_app_domain="${APPS_DOMAIN}" \
  -v buildpack_directory_key="$(output base .cf_buildpacks_bucket_name)" \
  -v droplet_directory_key="$(output base .cf_droplets_bucket_name)" \
  -v app_package_directory_key="$(output base .cf_packages_bucket_name)" \
  -v resource_directory_key="$(output base .cf_resource_pool_bucket_name)" \
  -v cf_blobstore_s3_kms_key_id="$(output base .cf_blobstore_s3_kms_key_id)" \
  -v external_database_type="$(output rds .cf_db_type)" \
  -v external_database_port="$(output rds .cf_db_port)" \
  -v external_uaa_database_name="uaa" \
  -v external_uaa_database_address="${CF_DB_ENDPOINT}" \
  -v external_uaa_database_password="${CF_DB_PASSWORD}" \
  -v external_uaa_database_username="${CF_DB_USERNAME}" \
  -v external_cc_database_name="cc" \
  -v external_cc_database_address="${CF_DB_ENDPOINT}" \
  -v external_cc_database_password="${CF_DB_PASSWORD}" \
  -v external_cc_database_username="${CF_DB_USERNAME}" \
  -v external_bbs_database_name="bbs" \
  -v external_bbs_database_address="${CF_DB_ENDPOINT}" \
  -v external_bbs_database_password="${CF_DB_PASSWORD}" \
  -v external_bbs_database_username="${CF_DB_USERNAME}" \
  -v external_routing_api_database_name="routing_api" \
  -v external_routing_api_database_address="${CF_DB_ENDPOINT}" \
  -v external_routing_api_database_password="${CF_DB_PASSWORD}" \
  -v external_routing_api_database_username="${CF_DB_USERNAME}" \
  -v external_policy_server_database_name="policy_server" \
  -v external_policy_server_database_address="${CF_DB_ENDPOINT}" \
  -v external_policy_server_database_password="${CF_DB_PASSWORD}" \
  -v external_policy_server_database_username="${CF_DB_USERNAME}" \
  -v external_silk_controller_database_name="silk_controller" \
  -v external_silk_controller_database_address="${CF_DB_ENDPOINT}" \
  -v external_silk_controller_database_password="${CF_DB_PASSWORD}" \
  -v external_silk_controller_database_username="${CF_DB_USERNAME}" \
  -v external_locket_database_name="locket" \
  -v external_locket_database_address="${CF_DB_ENDPOINT}" \
  -v external_locket_database_password="${CF_DB_PASSWORD}" \
  -v external_locket_database_username="${CF_DB_USERNAME}" \
  -v external_credhub_database_name="credhub" \
  -v external_credhub_database_address="${CF_DB_ENDPOINT}" \
  -v external_credhub_database_password="${CF_DB_PASSWORD}" \
  -v external_credhub_database_username="${CF_DB_USERNAME}"

