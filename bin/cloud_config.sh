#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

output() {
    FILE=$1
    QUERY=$2

    bin/outputs.sh $FILE | jq -r "$QUERY"
}

BOSH="bin/bosh_credentials.sh -e $ENVIRONMENT bosh"

$BOSH update-cloud-config -n \
  ./cloud-config/cf/cloud-config.yml \
  -o ./operations/cloud-config/router-extensions.yml \
  -o ./operations/cloud-config/cf-scheduler-extensions.yml \
  -o ./operations/cloud-config/cf-s3-blobstore.yml \
  -o ./operations/cloud-config/cf-rds-sec-group.yml \
  -v az1="$(jq -r .availability_zones[0] < data/$ENVIRONMENT.tfvars)" \
  -v az2="$(jq -r .availability_zones[1] < data/$ENVIRONMENT.tfvars)" \
  -v az3="$(jq -r .availability_zones[2] < data/$ENVIRONMENT.tfvars)" \
  -v private_subnet_az1_gateway="$(output base .internal_subnet_gateway_ips[0])" \
  -v private_subnet_az2_gateway="$(output base .internal_subnet_gateway_ips[1])" \
  -v private_subnet_az3_gateway="$(output base .internal_subnet_gateway_ips[2])" \
  -v reserved_az1_cidr="$(output base .internal_subnet_reserved_cidr_blocks[0])" \
  -v reserved_az2_cidr="$(output base .internal_subnet_reserved_cidr_blocks[1])" \
  -v reserved_az3_cidr="$(output base .internal_subnet_reserved_cidr_blocks[2])" \
  -v private_dns_nameserver="$(output base .vpc_dns_nameserver)" \
  -v internal_security_group="$(output base .cf_internal_security_group_id)" \
  -v private_subnet_az1_id="$(output base .internal_subnet_ids[0])" \
  -v private_subnet_az2_id="$(output base .internal_subnet_ids[1])" \
  -v private_subnet_az3_id="$(output base .internal_subnet_ids[2])" \
  -v private_subnet_az1_cidr="$(output base .internal_subnet_cidr_blocks[0])" \
  -v private_subnet_az2_cidr="$(output base .internal_subnet_cidr_blocks[1])" \
  -v private_subnet_az3_cidr="$(output base .internal_subnet_cidr_blocks[2])" \
  -v cf-router-target-group-name="$(output base .cf_router_target_group_name)" \
  -v cf-router-lb-internal-security-group-id="$(output base .cf_router_lb_internal_security_group_id)" \
  -v cf-internal-security-group-id="$(output base .cf_internal_security_group_id)" \
  -v cf-ssh-internal="$(output base .cf_ssh_internal_security_group_id)" \
  -v cf-ssh-lb="$(output base .cf_ssh_lb_name)" \
  -v cf_s3_iam_instance_profile="$(output base .cf_s3_iam_instance_profile)" \
  -v cf-rds-client-security-group="$(output base .cf_rds_client_security_group_id)"

#   -o ./operations/cloud-config/prometheus.yml \
#   -v prometheus_subnet_az1_cidr="$(jq -r .prometheus_subnet_az1_cidr < prometheus-vars.json)" \
#   -v prometheus_subnet_az1_id="$(jq -r .prometheus_subnet_az1_id < prometheus-vars.json)" \
#   -v prometheus_security_group="$(jq -r .prometheus_security_group_id < prometheus-vars.json)" \
#   -v prometheus_subnet_az1_gateway="$(jq -r .prometheus_subnet_az1_cidr < prometheus-vars.json | sed 's#0/24#1#')" \
#   -v grafana_target_group_name="$(jq -r .grafana_target_group_name < prometheus-vars.json)" \
#   -v prometheus_target_group_name="$(jq -r .prometheus_target_group_name < prometheus-vars.json)" \
#   -v alertmanager_target_group_name="$(jq -r .alertmanager_target_group_name < prometheus-vars.json)" 

$BOSH cloud-config > data/$ENVIRONMENT-cloud-config.yml