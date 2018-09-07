#!/bin/bash

set -euo pipefail

FILES=

while getopts e:f: option; do
  case $option in
    e) export ENVIRONMENT="$OPTARG";;
    f) FILES="$OPTARG $FILES";;
  esac
done

: $ENVIRONMENT

cd data
trap 'cd -' EXIT

[ -z "$FILES" ] && FILES=""$ENVIRONMENT-*""
for FILE in $FILES; do
  [[ $FILE = *backup ]] && continue
  aws s3 cp "$FILE" "s3://ons-paas-${ENVIRONMENT}-states/$FILE" --acl=private
done