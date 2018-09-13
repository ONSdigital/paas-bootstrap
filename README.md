# PaaS Bootsrap

We use the code in this repository to bootstrap our AWS PaaS environment. The normal flow is:

1. Create the Infrastructure under which the Concourse, BOSH and PaaS systems will live
2. Deploy a BOSH director
3. Deploy CF, Concourse, Prometheus, etc.
4. Deploy the automation pipelines for upgrades

## Pre-requisites

- AWS CLI
- Terraform CLI
- BOSH CLI
- CF CLI
- CF Management CLIs
- Credhub CLI
- UAA CLI
- PSQL client
- MySQL client
- Fly [CLI](https://concourse-ci.org/download.html)
- [yq](https://github.com/mikefarah/yq) (or, `brew install yq`)
- [jq](https://stedolan.github.io/jq/) (or, `brew install jq`)

## Creating a new environment

1. Update submodules

```sh
  git submodule update --init
```

2. Create your environment directory and vars file

```sh
mkdir data
touch data/<env>.tfvars
```

You'll need to create a `<env>.tfvars` file:

```json
{
    "environment": "<env>",
    "region": "eu-west-1",
    "availability_zones": ["eu-west-1a", "eu-west-1b", "eu-west-1c"],
    "parent_dns_zone": "<parent domain>",
    "ingress_whitelist": ["0.0.0.0/0"],
    "vpc_cidr_block": "10.121.0.0/16",
    "cidr_blocks": {
        "public":     ["10.121.0.0/24", "10.121.1.0/24", "10.121.2.0/24"],
        "internal":   ["10.121.8.0/22", "10.121.12.0/22", "10.121.16.0/22"],
        "services":   ["10.121.28.0/22", "10.121.32.0/22", "10.121.36.0/22"],
        "rds":        ["10.121.50.0/24", "10.121.51.0/24", "10.121.52.0/24"],
        "prometheus": ["10.121.53.0/24", "10.121.54.0/24", "10.121.55.0/24"],
        "concourse":  ["10.121.56.0/24", "10.121.57.0/24", "10.121.58.0/24"]
    }
}
```

The `vpc_cidr_block` parameter is an array of IP ranges that you want to be able to access
the PaaS. It should *not* be `0.0.0.0/0`.

The `cidr_blocks` parameter specifies the IP subnet CIDR block ranges for each subnet and availability zone.
This is specified to allow you to define exactly how big to make each subnet. (We could have automatically
generated these values, but feel it is more comprehensible to view it in the base variables)

3. Create an AWS user and access credentials

You will need to create (manually) an AWS user and generate access and secret keys via the AWS console.

4. Create the PaaS

```sh
  export AWS_ACCESS_KEY=<your AWS key id>
  export AWS_SECRET_ACCESS_KEY=<your AWS secret key>
  export ENVIRONMENT=<env>
  make terraform
  make rds
  make databases # you will need to wait a bit after the previous step to give RDS time to initialise
  make bosh
  make runtime_config cloud_config stemcells
  make concourse
  make cf
  make prometheus
```

You can specify AWS_PROFILE, rather than the two AWS secrets, for every step except `make bosh`.
The `bosh create-env` command currently does not handle AWS_PROFILE correctly.

5. Deploy the Concourse pipelines

```sh
  export ENVIRONMENT=<env>
  make set_concourse_secrets
  make pipelines
```

## Connecting to components

### Connecting to Concourse

The dns name of Concourse is found by:

```sh
  bin/outputs.sh -e <env> | jq .concourse_fqdn
```

Go to `https://<concourse_fqdn>` to login.

The username is `admin` and you can get the password through:

```sh
bin/concourse_password.sh -e <env>
```


### SSHing onto the jumpbox

```sh
bin/jumpbox_ssh -e <env>
```

### Logging in to BOSH

```sh
  bin/bosh_credentials.sh -e <env>
  # spins up a subshell with a Socks5 proxy connection via jump box to BOSH
```

or, you can run a bosh command:

```sh
  bin/bosh_credentials.sh -e <env> bosh vms
```

### Logging into CF as admin

The CF API URL is `https://api.system.<env>.<domain>`.

```sh
cf login -a https://api.system.<env>.<parent domain> -u admin -p $(bin/cf_password.sh -e <env>)
```

### Connecting to Prometheus components

```sh
bin/prometheus_credentials.sh -e <env>
```

And use the displayed output to point the browser at the desired Prometheus component.

## Versions

| Component   | Version |
| ----------- | ------- |
| concourse   | v4.1.0  |
| cf          | v4.2.0  |
| bosh        | v1.2.0  |
| prometheus  | v23.2.0 |
| rabbitmq    | v37.0.0 |

## LICENCE

Copyright (c) 2018 Crown Copyright (Office for National Statistics)

Released under MIT license, see [LICENSE](LICENSE) for details.
