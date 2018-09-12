#!/bin/bash

set -euo pipefail

while getopts e: option; do
  case $option in
    e) export ENVIRONMENT="$OPTARG";;
  esac
done

: $ENVIRONMENT

output() {
    FILE=$1
    QUERY=$2

    bin/outputs.sh $FILE | jq -r "$QUERY"
}

REDIS_USER=$(output base .redis_user_name)
KEY_METADATA=$(aws iam list-access-keys --user-name $REDIS_USER --max-items 1)

if [[ $(echo $KEY_METADATA | jq  '.AccessKeyMetadata[] | length > 0') ]]; then
 CREDHUB_KEY=$(bin/credhub_credentials.sh -e $ENVIRONMENT credhub get -n /cf/redis/aws_access_key_id -j | jq -r .value)
 AWS_KEY=$(echo $KEY_METADATA | jq -r .AccessKeyMetadata[0].AccessKeyId)
 if [ -z $CREDHUB_KEY ] || [ "${CREDHUB_KEY}" != "${AWS_KEY}" ]; then
     echo "AWS credential is not in credhub, but it exists in AWS. Please remove this account manually from AWS and rerun."
     exit 1
 else
     echo "AWS credential is already in credhub."
 fi 
else
 secrets=$(aws iam create-access-key --user-name $REDIS_USER)
 bin/credhub_credentials.sh -e $ENVIRONMENT credhub set -n /cf/redis/aws_access_key_id --type value --value $(echo $secrets | jq -r .AccessKey.AccessKeyId)
 bin/credhub_credentials.sh -e $ENVIRONMENT credhub set -n /cf/redis/aws_secret_access_key_id --type value --value $(echo $secrets | jq -r .AccessKey.SecretAccessKey)
 bin/credhub_credentials.sh -e $ENVIRONMENT credhub set -n /cf/redis/broker_user --type value --value "redis_admin"
 bin/credhub_credentials.sh -e $ENVIRONMENT credhub set -n /cf/redis/broker_password --type value --value "$(output base .redis_broker_password)"
 bin/credhub_credentials.sh -e $ENVIRONMENT credhub set -n /cf/redis/service_uuid --type value --value "$(uuidgen)"
fi
