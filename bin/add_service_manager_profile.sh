#!/bin/bash
#
# This script will set up config for cf-mgmt to create application security
# groups (ASGs) for a deployment profile
#
# cd profiles/<env>
# ./bin/add_service_manager_profile.sh

# Requires cf-mgmt-config to be installed on PATH
hash cf-mgmt-config 2>/dev/null || { echo >&2 "Requires cf-mgmt-config but it's not installed.  Aborting."; exit 1; }

ASG="[
  {
    \"destination\": \"10.0.20.0/24\",
    \"ports\": \"5432\",
    \"protocol\": \"tcp\"
  },
  {
    \"destination\": \"10.0.21.0/24\",
    \"ports\": \"5432\",
    \"protocol\": \"tcp\"
  },
  {
    \"destination\": \"10.0.22.0/24\",
    \"ports\": \"5432\",
    \"protocol\": \"tcp\"
  }
]"

cf-mgmt-config add-asg --asg=postgres_networks --path=<(echo ${ASG}) --type default --override