#!/bin/bash

set -euo pipefail

: ${TAG:=latest}

# Assumes you have logged into Docker Hub

IMAGE="onsdigital/paas-ci-gp:$TAG"

docker build -t "$IMAGE" docker

docker push "$IMAGE"