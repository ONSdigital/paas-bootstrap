# PaaS Bootsrap

We use the code in this repository to bootstrap our AWS PaaS environment. The normal flow is:

1. Create the VPC under which the PaaS systems will live
2. Create a Concourse using `bosh create-env`
3. Deploy the pipelines that will spin up BOSH and CloudFoundry
4. Sit back and wait

## Pre-requisites

- Terraform CLI
- [yq](https://github.com/mikefarah/yq) (or, `brew install yq`)
- [jq](https://stedolan.github.io/jq/) (or, `brew install jq`)

## Creating a new environment

You'll need to create a `<env>_vpc.tfvars` file with `az`, `region` and `parent_dns_zone`:

```sh
az = "eu-west-1a"
region = "eu-west-1"
parent_dns_zone = "<domain>"
```

Example command:

```sh
git submodule update --init
ENVIRONMENT=<choose_a_name> AWS_ACCESS_KEY_ID=<your_key_id> AWS_SECRET_ACCESS_KEY=<your_secret_key> 
make concourse
```

Where:

- `ENVIRONMENT` - a name for your environment
- `AWS_ACCESS_KEY_ID` - your aws access key id
- `AWS_SECRET_ACCESS_KEY` - your aws secret access key

## Connecting to Concourse

The dns name of Concourse is found by:

```sh
terraform output -state=<env>_concourse.tfstate.json concourse_fqdn
```

Go to `https://<concourse_fqdn>` to login.

The username is `admin` and you can get the password through:

```sh
bosh int --path /admin_password <env>_concourse.creds.yml
```

## LICENCE

Copyright (c) 2018 Crown Copyright (Office for National Statistics)

Released under MIT license, see [LICENSE](LICENSE) for details.
