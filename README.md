# PaaS Bootsrap

We use the code in this repository to bootstrap our AWS PaaS environment. The normal flow is:

1. Create the VPC under which the PaaS systems will live
2. Create a Concourse using `bosh create-env`
3. Deploy the pipelines that will spin up BOSH and CloudFoundry
4. Sit back and wait

## Pre-requisites

- AWS CLI
- Terraform CLI
- Fly [CLI](https://concourse-ci.org/download.html)
- [yq](https://github.com/mikefarah/yq) (or, `brew install yq`)
- [jq](https://stedolan.github.io/jq/) (or, `brew install jq`)

## Creating a new environment

You'll need to create a `<env>_vpc.tfvars` file with `az1`, `az2`, `region` and `parent_dns_zone`:

> **Note**: Multiple AZs are required in order to deploy an AWS ALB.

> set ingress_whitelist to the CIDRs that may access Concourse

```json
{
"az1": "eu-west-1a",
"az2": "eu-west-1b",
"region": "eu-west-1",
"parent_dns_zone": "<domain>",
"ingress_whitelist": ["0.0.0.0/0"],
"slack_webhook_uri": "https://hooks.slack.com/services/<generated uri>"
}
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

You can specify AWS_PROFILE, rather than the two AWS secrets, for every step except for `make concourse`.
The `bosh create-env` command currently does not handle AWS_PROFILE correctly.

## Connecting to Concourse

The dns name of Concourse is found by:

```sh
terraform output -state=<env>_concourse.tfstate.json concourse_fqdn
```

Go to `https://<concourse_fqdn>` to login.

The username is `admin` and you can get the password through:

```sh
bin/concourse_password.sh -e <env>
```

or using

```sh
make concourse_password ENVIRONMENT=<env>
```

## Testing that Concourse works

```sh
ENVIRONMENT=<env> AWS_ACCESS_KEY_ID=<your_key_id> AWS_SECRET_ACCESS_KEY=<your_secret_key> make test_pipeline
fly -t <env> trigger-job -j test/pipeline-test -w
```

## Installing the deployment pipeline

The `deploy_pipeline` pipeline will spin up the jump box and BOSH director.

```sh
ENVIRONMENT=<env> AWS_ACCESS_KEY_ID=<your_key_id> AWS_SECRET_ACCESS_KEY=<your_secret_key> make deploy_pipeline
fly -t <env> trigger-job -j deploy_pipeline/terraform-jumpbox -w
```

If you are deploying from a branch, you should also specify it with the `BRANCH` environment variable, so that the pipeline will trigger correctly.

```sh
BRANCH=<your git branch> ... make deploy_pipeline
```


## Logging in to BOSH

Once the deployment pipeline has run to completion, you can set up your connection to BOSH easily using:

```sh
  bin/bosh_credentials.sh -e <env> -f
  # spins up a subshell with a Socks5 proxy connection via jump box to BOSH
```

or

```sh
  source bin/bosh_credentials.sh -e <env>
  # sets up the Socks5 proxy connection as above, but it's now your job to kill it
  # it also sets BOSH_CLIENT, BOSH_CLIENT_SECRET environment variables
```

## Deploying service brokers

### RDS

The security groups and subnets are generated as part of the `cf-deploy` job.
Requires a running RDS instance to exist in the specified subnet group.

```
git clone https://github.com/cloudfoundry-community/rds-broker.git
cd rds-broker
# Amend manifest.yml to correct details for your instance (see below)
# Amend catalog.yaml to remove the paid micro- and medium- options
cf push
cf create-service-broker rds <broker_username> <broker_password> <url_of_running_app>
cf create-service rds shared-psql <desired_service_name>
```

There will now be a service available for binding to apps

```yaml
---
applications:
- name: rds-broker
  memory: 256M
  env:
    DB_URL: <url_of_rds_instance>
    DB_NAME: rds_broker
    DB_USER: <instance_username>
    DB_PASS: <instance_password>
    DB_PORT: 5432
    DB_TYPE: postgres
    AWS_REGION: <region>
    AWS_SEC_GROUP: <security_group_id_for_rds>
    AWS_DB_SUBNET_GROUP: <name_of_subnet_group_containing_rds_instance>
    GOVERSION: go1.10.3
    ENC_KEY: <encryption_key_of_db>
    DB_SSLMODE: require
    AUTH_USER: <username_to_connect_to_broker>
    AUTH_PASS: <password_to_connect_to_broker>
```

## LICENCE

Copyright (c) 2018 Crown Copyright (Office for National Statistics)

Released under MIT license, see [LICENSE](LICENSE) for details.
