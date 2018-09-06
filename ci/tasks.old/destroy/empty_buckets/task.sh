#!/bin/bash

set -euo pipefail

: $ONS_PREFIX
: $ENVIRONMENT
: $NAMESPACE

prefix="${ONS_PREFIX}-${ENVIRONMENT}-${NAMESPACE}"

NAMES=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, '${prefix}')].Name" --output text)

echo "Removing all files/versions from ${prefix}-* (${NAMES})"

function emptyBucket {
  local bucket="$1";
  echo "Emptying ${bucket}"
  aws s3 rm "s3://${bucket}" --recursive
}

function emptyVersionedBucket {
  local bucket="$1";

  echo "Deleting versions and delete markers from ${bucket}"

  aws s3api list-object-versions --bucket "${bucket}" | \
    jq -r '.Versions + .DeleteMarkers | .[] |  @text "\(.Key) \(.VersionId)"' | \
    while read key versionId
    do
      echo "- $bucket $key $versionId"
      aws s3api delete-object --bucket "${bucket}" --key "${key}" --version-id "${versionId}"
    done

  return 0
}

for name in $NAMES
do
  emptyVersionedBucket "${name}"
  emptyBucket "${name}"
done
