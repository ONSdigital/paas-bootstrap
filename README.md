# PaaS Bootsrap

We use the code in this repository to bootstrap our AWS PaaS environment. The normal flow is:

1. Create the VPC under which the PaaS systems will live
2. Create a Concourse using `bosh create-env`
3. Deploy the pipelines that will spin up BOSH and CloudFoundry
4. Sit back and wait

## Pre-requisites

- Terraform CLI
- [yq](https://github.com/mikefarah/yq) (or, `brew install yq`)

## LICENCE

Copyright (c) 2018 Crown Copyright (Office for National Statistics)

Released under MIT license, see [LICENSE](LICENSE) for details.
