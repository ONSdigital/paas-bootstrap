#!/bin/sh

# set -eu

# # This script follows the recipe set out in the README for cf-acceptance-tests

CONFIG="$PWD/$CONFIG"
cd cf-acceptance-tests-git
./bin/update_submodules
# ./bin/test



function test {

if [ ! -f "${CONFIG}" ]; then
  echo "FAIL: \$CONFIG must be set to the path of an integration config JSON file"
  exit 1
fi

echo "Printing sanitized \$CONFIG"
echo "==1=="
grep -v -e password -e private_docker_registry_ -e credhub_secret -e honeycomb_write_key $CONFIG

bin_dir=$(dirname "${BASH_SOURCE[0]}")
project_go_root="${bin_dir}/../../../../../"

pushd "${project_go_root}" > /dev/null
  project_gopath=$PWD
popd > /dev/null

export GOPATH="${project_gopath}"
export PATH="${project_gopath}/bin":$PATH

export RUN_ID=$(openssl rand -hex 16)

echo "====2===="
go install -v github.com/cloudfoundry/cf-acceptance-tests/vendor/github.com/onsi/ginkgo/ginkgo

echo "====3===="
params="$@"
echo "PARAMS ==$params== "
# ginkgo "$params"

}

test -v