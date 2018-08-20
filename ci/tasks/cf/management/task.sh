#!/usr/bin/env bash
set -e

: ENVIRONMENT

set -a
source cf_mgmt_vars/env
set +a

if [[ ${ENVIRONMENT} = "eng"* ]]; then
  profile="engineering"
else
  profile="${ENVIRONMENT}"
fi

cd paas-bootstrap-git/profiles/${profile}

cf-mgmt-config update-space --org=paas --space=test --developer-user=cf_test_user
cf-mgmt create-orgs
cf-mgmt create-spaces