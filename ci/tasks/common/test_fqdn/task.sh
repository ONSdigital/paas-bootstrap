#!/bin/bash

set -eux 

: $ENVIRONMENT
: $HOST
: $DOMAIN
: ${EXPECTED_OUTCOME:=success}

# FIXME: our .tfstate variable naming isn't consistent, bosh/concourse/jumbox/vpc are called differently
# FIXME: inconsistent naming of external/public IP address variable in terraform
# WORKAROUND APPLIED
FQDN="$HOST.$DOMAIN"
# RESOLVE=$(host "$FQDN" | awk '/has address/ { print $4 }')
# TFSTATE=$(aws s3 ls s3://${ENVIRONMENT}-states/${HOST}/ | grep 'tfstate' | awk '{ print $4 }')
# aws s3 cp "s3://${ENVIRONMENT}-states/${HOST}/${TFSTATE}" ${TFSTATE}


INTERNAL_IP=$(bosh int --path /instance_groups/name=jumpbox/networks/name=private/static_ips/0 jumpbox-manifest-s3/jumpbox.yml)



TFREC=$(terraform output -state=${TFSTATE} | awk "/${EXTIP_STRING}/ { print \$3 ; exit }")

# if [ "$RESOLVE" == "$TFREC" ]; then
if [ "$RESOLVE" == "0.0.0.0" ]; then
  echo -e "Match!\nResolved IP of $HOST.$DOMAIN matches its records in AWS." 
  exit 0
else 
  echo "Failed to match $HOST.$DOMAIN to its advertised IP address."
  exit 1
fi

exit 1


