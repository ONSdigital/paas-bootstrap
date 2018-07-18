#!/bin/sh

set -eu

# This script follows the recipe set out in the README for cf-acceptance-tests

CONFIG="$PWD/$CONFIG"
cd cf-acceptance-tests-git
./bin/update_submodules
./bin/test