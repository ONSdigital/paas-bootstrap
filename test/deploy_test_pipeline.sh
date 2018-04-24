#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

USERNAME=admin

FQDN=$(terraform output -state=${ENVIRONMENT}_concourse.tfstate.json concourse_fqdn)
PASSWORD=$(bosh int --path /admin_password ${ENVIRONMENT}_concourse.creds.yml)

fly login -t "$ENVIRONMENT" -u "$USERNAME" -p "$PASSWORD" -c "https://$FQDN"
fly -t "$ENVIRONMENT" set-pipeline -c test/test_pipeline.yml -p test -n
fly -t "$ENVIRONMENT" unpause-pipeline -p test 

