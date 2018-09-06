#!/usr/bin/env bash
set -e

: ENVIRONMENT

set -a
source cf_user_credentials/env
set +a

cf login -a $API -u $USER_ID -p $PASSWORD -o paas -s services

cd rds-broker-git/

# do manifest!

cf push
cf create-service-broker SERVICE-NAME USER PASS https://BROKER-URL
cf enable-service-access rds


exit 0
