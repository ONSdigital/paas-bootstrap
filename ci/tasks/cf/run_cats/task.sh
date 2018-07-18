#!/bin/sh

set -eu

CONFIG="$PWD/$CONFIG"
cd cf-acceptance-tests-git
./bin/test