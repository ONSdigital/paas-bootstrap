#!/bin/bash

set -euo pipefail

FILES=
OPTIONAL=
EXISTS=

while getopts e:f:ox option; do
  case $option in
    e) export ENVIRONMENT="$OPTARG";;
    f) FILES="$OPTARG $FILES";;
    o) OPTIONAL=true;;
    x) EXISTS=true;;
  esac
done

: $ENVIRONMENT

[ "$OPTIONAL" = true ] && set +e

if [ -z "$FILES" ]; then
  aws s3 cp --recursive "s3://ons-paas-${ENVIRONMENT}-states" "data/" --acl=private
else
  for FILE in $FILES; do
    [ "$EXISTS" = true -a -f data/$FILE ] && continue
    aws s3 cp "s3://ons-paas-${ENVIRONMENT}-states/$FILE" "data/" --acl=private
  done
fi

exit 0