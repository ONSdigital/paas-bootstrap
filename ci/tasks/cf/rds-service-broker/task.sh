#!/usr/bin/env bash
set -e

: ENVIRONMENT

set -a
source cf_user_credentials/env
set +a

cf login -a $API -u $USER_ID -p $PASSWORD -o paas -s test

exit 0
