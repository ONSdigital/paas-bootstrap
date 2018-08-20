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

cf-mgmt create-orgs
cf-mgmt create-spaces
cf-mgmt update-org-users
cf-mgmt update-space-users