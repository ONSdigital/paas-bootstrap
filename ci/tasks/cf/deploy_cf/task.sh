#!/bin/bash

set -euo pipefail

bosh deploy ./cf-manifest-s3/cf.yml

