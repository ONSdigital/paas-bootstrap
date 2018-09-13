
.EXPORT_ALL_VARIABLES:
.PHONY: terraform

# Environment variables that you have to set yourself:
#
# ENVIRONMENT
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# You could override these, but you really shouldn't
VAR_FILE = ${ENVIRONMENT}_vpc.tfvars

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

terraform: ## create main terraform environment
	@bin/terraform.sh apply

terraform_init: ## initialize terraform provider
	@terraform init terraform/base	

terraform_plan: ## plan what would be applied if we ran make terraform
	@bin/terraform.sh plan

outputs: ## base terraform outputs
	@bin/outputs.sh

rds: ## create rds instances
	@bin/rds.sh apply

databases: ## create databases
	@bin/databases.sh

bosh: ## create bosh
	@bin/create_bosh.sh

runtime_config: ## Deploy runtime config
	@bin/runtime_config.sh

cloud_config: ## Deploy cloud config	
	@bin/cloud_config.sh

stemcells: ## Upload stemcells
	@bin/stemcells.sh

cf: ## Deploy CF
	@bin/deploy_cf.sh

prometheus: ## Deploy Prometheus
	@bin/deploy_prometheus.sh

rabbitmq: ## Deploy RabbitMQ service broker
	@bin/deploy_rabbitmq.sh

concourse: ## Deploy concourse
	@bin/deploy_concourse.sh	

login_fly: ## Log in to fly
	@bin/login_fly.sh

set_concourse_secrets: ## Set the secrets that Concourse needs to run its pipelines
	@bin/set_concourse_secrets.sh

pipelines: login_fly ## Deploy pipelines
	@ci/cf_pipeline.sh

destroy_concourse: ## Delete the concourse deployment
	@bin/destroy_deployment.sh concourse

destroy_rabbitmq: ## Delete the rabbitmq deployment
	@bin/destroy_deployment.sh rabbitmq

destroy_prometheus: ## Delete the prometheus deployment
	@bin/destroy_deployment.sh prometheus

destroy_cf: ## Delete the CF deployment
	@bin/destroy_deployment.sh cf

destroy_bosh: ## Kill off bosh
	@bin/destroy_bosh.sh

destroy_rds: ## destroy the RDS instances
	@bin/rds.sh destroy

destroy_terraform: ## destroy main terraform environment
	@bin/terraform.sh destroy

decode_aws_error: ## Decode AWS message
	@aws sts decode-authorization-message --encoded-message ${DECODE_MESSAGE} | jq -r .DecodedMessage | jq .

set_redis_secrets: ## Set the secrets for Redis broker
	@bin/set_redis_secrets.sh

redis: ## Deploy Redis (Elasticache)
	@bin/deploy_redis.sh
