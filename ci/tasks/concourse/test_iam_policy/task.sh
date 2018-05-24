#!/bin/bash

: ${BUCKET:=omg-this-bucket-no-existy}

touch foo
aws s3 mb "s3://$BUCKET" || exit 0
echo "Oh crap, managed to create an S3 bucket ($BUCKET) and put stuff in it"
echo
aws s3 rb "s3://$BUCKET"
exit 1