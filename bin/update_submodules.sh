#!/bin/bash

set -euo pipefail


git submodule update --init

cd concourse-bosh-deployment
git checkout v4.1.0
cd ..

cd bosh-deployment
git checkout 7375c31d59018203911da3881334f09d8e70deb5
cd ..

cd cf-deployment
git checkout v4.2.0
cd ..

cd prometheus-boshrelease
git checkout v23.2.0
cd ..

cd cf-rabbitmq-multitenant-broker-release 
git checkout v37.0.0
cd ..

cd elasticache-broker
git checkout d0a66eab280793e3d2f342996e6c16a5cc6f9c8f
cd ..