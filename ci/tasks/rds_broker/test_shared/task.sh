#!/usr/bin/env bash

set -euo pipefail

set -a
source cf_user_credentials/env
set +a

cd cf-tests-git/rds

cf login -a $API -u $USER_ID -p $PASSWORD -o paas -s test

cf create-service rds  shared-psql paas-test-shared-rds

cf push paas-test-shared-rds-app

cf bind-service paas-test-shared-rds-app paas-test-shared-rds 

curl paas-test-shared-rds-app.$APPS_DOMAIN | grep "RDS service is OK"

cf delete paas-test-shared-rds-app -f -r

cf delete-service paas-test-shared-rds -f

exit 0