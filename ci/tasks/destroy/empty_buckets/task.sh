#!/bin/bash

set -euo pipefail

: $ONS_PREFIX
: $ENVIRONMENT
: $NAMESPACE

prefix=${ONS_PREFIX}-${ENVIRONMENT}-${NAMESPACE}

NAMES=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, '${prefix}')].Name" --output text)

echo "Removing all files/versions from ${prefix}-* (${NAMES})"

function isVersioned {
  version=$(aws s3api get-bucket-versioning --bucket ${bucket} | jq -r '.Status')
  if [ $version == "Enabled"]; then
    return 0
  else
    return 1
  fi
}

function deleteFiles {
  aws s3 rm s3://${bucket} --recursive --dryrun
}

function emptyBucket {

  echo "Emptying $1"
  local bucket=$1;

  local versions=$(aws s3api list-object-versions --bucket "$bucket" | jq '.Versions')
  local markers=$(aws s3api list-object-versions --bucket "$bucket" | jq '.DeleteMarkers')
  count=$(($(echo $versions | jq 'length')-1))

  if [ $count -gt -1 ]; then
    echo "removing files"
    for i in $(seq 0 $count); do
      key=$(echo $versions | jq ".[$i].Key" | sed -e 's/\"//g')
      versionId=$(echo $versions | jq ".[$i].VersionId" | sed -e 's/\"//g')
      echo "- $bucket $key $versionId"
      aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$versionId"
    done
  fi

  count=$(($(echo $markers | jq 'length')-1))

  if [ $count -gt -1 ]; then
    echo "removing delete markers"

    for i in $(seq 0 $count); do
      key=$(echo $markers | jq ".[$i].Key" | sed -e 's/\"//g')
      versionId=$(echo $markers | jq ".[$i].VersionId" | sed -e 's/\"//g')
      echo "- $bucket $key $versionId"
      aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$versionId"
    done
  fi

  return 0
}

for name in $NAMES
do
  if isVersioned ${name}; then
    deleteFiles ${name}
  else
    emptyBucket ${name}
  fi
done