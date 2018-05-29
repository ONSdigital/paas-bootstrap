#!/bin/bash

set -euo pipefail

bosh deploy ./cf-manifests/cf.yml

