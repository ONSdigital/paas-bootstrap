
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

destroy_terraform: ## destroy main terraform environment
	@bin/terraform.sh destroy

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

concourse: ## Deploy concourse
	@bin/deploy_concourse.sh	

login_fly: ## Log in to fly
	@bin/login_fly.sh

pipelines: login_fly ## Deploy pipelines
	@ci/cf_pipeline.sh

decode_aws_error: ## Decode AWS message
	@aws sts decode-authorization-message --encoded-message ${DECODE_MESSAGE} | jq -r .DecodedMessage | jq .

