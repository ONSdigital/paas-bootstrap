#!/bin/bash

set -eu

: $BUCKET
: $FILE

aws s3 rm "s3://$BUCKET/$FILE" || true