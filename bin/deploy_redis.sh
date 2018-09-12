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

REDIS_SUBMODULE="./elasticache-broker"

# TODO provide credentials from credhub
bosh int $REDIS_SUBMODULE/manifest.yml \
   -o ./operations/redis/credentials.yml \
   -v aws_access_key_id="$(bin/credhub_credentials.sh -e $ENVIRONMENT credhub get -n /cf/redis/aws_access_key_id -j | jq -r .value)" \
   -v aws_secret_access_key="$(bin/credhub_credentials.sh -e $ENVIRONMENT credhub get -n /cf/redis/aws_secret_access_key_id -j | jq -r .value)" \
  > foo.yml

cat foo.yml

REDIS_CONFIG="elasticache-broker/config.json"
touch $REDIS_CONFIG

cleanup() {
  rm -f $REDIS_CONFIG
}

trap cleanup EXIT

REDIS_BROKER_USER='test_user'
REDIS_BROKER_PASSWORD='test_password'
REDIS_SERVICE_UUID="test_uuid"
REDIS_SERVICE_NAME="test_redis_service_name"
REDIS_SERVICE_TAG="test_tag"
# Create redis subnet group
REDIS_CACHE_SUBNET_GROUP_NAME="$(output base .redis_cache_subnet_group_name)" 
REDIS_CACHE_SECURITY_GROUP="$(output base .redis_security_group_name)"
REGION="$(jq -r .region < data/$ENVIRONMENT.tfvars)"
jq '.username = "'${REDIS_BROKER_USER}'" |
 .password = "'${REDIS_BROKER_PASSWORD}'" |
 .elasticache_config.region = "'${REGION}'" |
 .elasticache_config.catalog.services[0].id = "'${REDIS_SERVICE_UUID}'" |
 .elasticache_config.catalog.services[0].tags[0] = "'${REDIS_SERVICE_TAG}'" |
 .elasticache_config.catalog.services[0].name = "'${REDIS_SERVICE_NAME}'" |
 .elasticache_config.catalog.services[0].plans[].elasticache_properties.cache_subnet_group_name = "'${REDIS_CACHE_SUBNET_GROUP_NAME}'" |
 .elasticache_config.catalog.services[0].plans[].elasticache_properties.cache_security_groups[0]= "'${REDIS_CACHE_SECURITY_GROUP}'" ' \
 $REDIS_SUBMODULE/config-sample.json > "$REDIS_CONFIG"

cat $REDIS_CONFIG