# PaaS Bootsrap

We use the code in this repository to bootstrap our AWS PaaS environment. The normal flow is:

1. Create the VPC under which the PaaS systems will live
2. Create a Concourse using `bosh create-env`
3. Deploy the pipelines that will spin up BOSH and CloudFoundry
4. Sit back and wait

## Pre-requisites

- Terraform CLI
- [yq](https://github.com/mikefarah/yq) (or, `brew install yq`)

## Creating a new environment

You'll need to create a `<env>_vpc.tfvars` file with `az` and `region`:

```sh
az = "eu-west-1a"
region = "eu-west-1"
```

Example command:

```sh
ENVIRONMENT=<choose_a_name> AWS_ACCESS_KEY_ID=<your_key_id> AWS_SECRET_ACCESS_KEY=<your_secret_key> make concourse
```

Where:

- `ENVIRONMENT` - a name for your environment
- `AWS_ACCESS_KEY_ID` - your aws access key id
- `AWS_SECRET_ACCESS_KEY` - your aws secret access key

## LICENCE

Copyright (c) 2018 Crown Copyright (Office for National Statistics)

Released under MIT license, see [LICENSE](LICENSE) for details.
