#!/bin/bash

set -euo pipefail
set -x

: $ONS_PREFIX
: $ENVIRONMENT
: $NAMESPACE

prefix=${ONS_PREFIX}-${ENVIRONMENT}-${NAMESPACE}

NAMES=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, '${prefix}')].Name" --output text)

echo "Removing all versions from ${prefix}-* (${NAMES})"

function emptyBucket {

  echo "Emptying $1"
  local bucket=$1;

  local versions=$(aws s3api list-object-versions --bucket "$bucket" | jq '.Versions')
  local markers=$(aws s3api list-object-versions --bucket "$bucket" | jq '.DeleteMarkers')
  let count=$(echo $versions | jq 'length')-1

  if [ $count -gt -1 ]; then
    echo "removing files"
    for i in $(seq 0 $count); do
      key=$(echo $versions | jq ".[$i].Key" | sed -e 's/\"//g')
      versionId=$(echo $versions | jq ".[$i].VersionId" | sed -e 's/\"//g')
      aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$versionId"
    done
  fi

  let count=$(echo $markers | jq 'length')-1

  if [ $count -gt -1 ]; then
    echo "removing delete markers"

    for i in $(seq 0 $count); do
      key=$(echo $markers | jq ".[$i].Key" | sed -e 's/\"//g')
      versionId=$(echo $markers | jq ".[$i].VersionId" | sed -e 's/\"//g')
      aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$versionId"
    done
  fi
}

for name in $NAMES
do
    emptyBucket ${name}
done