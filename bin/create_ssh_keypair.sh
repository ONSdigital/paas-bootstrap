#!/bin/bash

# Creates a new key pair if it doesn't already exist

set -euo pipefail

: $ENVIRONMENT
: $PRIVATE_KEY_FILE
: $PUBLIC_KEY_FILE

[ -f "$PRIVATE_KEY_FILE" ] && [ -f "$PUBLIC_KEY_FILE" ] && { echo "key pair $PRIVATE_KEY_FILE exists"; exit 0; }

ssh-keygen -t rsa -f "$PRIVATE_KEY_FILE" -N foobar
ssh-keygen -p -f "$PRIVATE_KEY_FILE" -P foobar -N ''
