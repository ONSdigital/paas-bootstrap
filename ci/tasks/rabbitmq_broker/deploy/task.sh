#!/bin/bash

set -euo pipefail

RABBITMQ_MANIFESTS=rabbitmq-broker-deployment-git/manifests
SYSTEM_DOMAIN="system.${DOMAIN}"
APPS_DOMAIN="apps.${DOMAIN}"

# TODO better configuration
RABBITMQ_STEMCELL_VERSION=3586.40
BROKER_PLAN_UUID=22F0B28C-B886-4123-B01B-95E54D3DE6DA
BROKER_UUID=568725FD-AD46-44CA-9853-621416E983A4

bosh -d rabbitmq deploy -n "$RABBITMQ_MANIFESTS"/cf-rabbitmq-broker-template.yml \
  -o "$RABBITMQ_MANIFESTS"/add-cf-rabbitmq.yml \
  -o paas-bootstrap-git/operations/rabbitmq/release.yml \
  -v deployment-name=rabbitmq \
  -v stemcell-version="'$RABBITMQ_STEMCELL_VERSION'" \
  -v system-domain="$SYSTEM_DOMAIN" \
  -v apps_domain="$APPS_DOMAIN" \
  -v multitenant-rabbitmq-broker-username=broker \
  -v product-name=p-rabbitmq \
  -v rabbitmq-management-username=admin \
  -v rabbitmq-broker-hostname=rabbitmq-multitenant-broker \
  -v rabbitmq-broker-password=broker \
  -v rabbitmq-broker-plan-uuid="$BROKER_PLAN_UUID" \
  -v rabbitmq-broker-protocol=https \
  -v rabbitmq-broker-username=broker \
  -v rabbitmq-broker-uuid="$BROKER_UUID" \
  -v rabbitmq-management-hostname=pivotal-rabbitmq \
  -v cf-admin-username=admin \
  -v cf-admin-password=$(bin/cf_password.sh -e "$ENVIRONMENT") \
  -v cluster-partition-handling-strategy=autoheal \
  -v haproxy-instances=1 \
  -v haproxy-stats-username=admin \
  -v rabbitmq-hosts=[]

