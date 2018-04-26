#!/bin/bash

# Creates a new key pair if it doesn't already exist

set -euo pipefail

: $ENVIRONMENT
: $PRIVATE_KEY_FILE
: $PUBLIC_KEY_FILE

aws s3 cp "s3://${ENVIRONMENT}-states/concourse/ssh-key.pem" "${PRIVATE_KEY_FILE}" || true
aws s3 cp "s3://${ENVIRONMENT}-states/concourse/ssh-key.pem.pub" "${PUBLIC_KEY_FILE}" || true

[ -f "$PRIVATE_KEY_FILE" ] && [ -f "$PUBLIC_KEY_FILE" ] &&
  {
    echo "Key pair $PRIVATE_KEY_FILE exists, skipping generation";
    exit 0
  }

ssh-keygen -t rsa -f "$PRIVATE_KEY_FILE" -N foobar
ssh-keygen -p -f "$PRIVATE_KEY_FILE" -P foobar -N ''

aws s3 cp "${PRIVATE_KEY_FILE}" "s3://${ENVIRONMENT}-states/concourse/ssh-key.pem" --acl=private
aws s3 cp "${PUBLIC_KEY_FILE}" "s3://${ENVIRONMENT}-states/concourse/ssh-key.pem.pub" --acl=private
