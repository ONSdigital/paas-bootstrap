
.EXPORT_ALL_VARIABLES:

# Environment variables that you have to set yourself:
#
# ENVIRONMENT
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# You could override these, but you really shouldn't
VAR_FILE = ${ENVIRONMENT}_vpc.tfvars
VPC_STATE_FILE = ${ENVIRONMENT}_vpc.tfstate.json
CONCOURSE_TERRAFORM_STATE_FILE = ${ENVIRONMENT}_concourse.tfstate.json
CONCOURSE_STATE_FILE = ${ENVIRONMENT}_concourse.state.json
CONCOURSE_CREDS_FILE = ${ENVIRONMENT}_concourse.creds.yml
PRIVATE_KEY_FILE = ${ENVIRONMENT}_concourse.pem
PUBLIC_KEY_FILE = ${PRIVATE_KEY_FILE}.pub

## FIXME: delete
JUMPBOX_TERRAFORM_STATE_FILE = ${ENVIRONMENT}_jumpbox.tfstate.json

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

require_vars:
	@bin/require_vars.sh

vpc: require_vars ## Setup a VPC to deploy concourse to
	@bin/create_vpc.sh

keypair: ## Create the SSH key pair used to log into the VMs
	@bin/create_ssh_keypair.sh

concourse_network: vpc keypair ## Setup networks for concourse to consume
	@bin/create_concourse_network.sh

concourse: concourse_network ## Deploy concourse with all prereqs
	@bin/deploy_concourse.sh

concourse_login: require_vars ## Logs fly into concourse
	@bin/login_fly.sh

test_pipeline: require_vars ## Deploy a test pipeline to concourse
	@test/deploy_test_pipeline.sh

test_s3_pipeline: require_vars ## Deploy a pipeline that tests S3 access to concourse
	@test/deploy_s3_test_pipeline.sh

deploy_pipeline: require_vars ## Deploy the CF deployment pipeline
	@ci/deploy_pipeline.sh

destruction_pipeline: require_vars ## Deploy the CF destruction pipeline
	@ci/destruction_pipeline.sh

docker_image:  ## Build the general-purpose tooled docker image for Concourse tasks
	@bin/create_docker_image.sh

destroy: destroy_bosh_network destroy_concourse_network ## Destroy an entire environment
	@bin/delete_vpc.sh

destroy_concourse_network: destroy_concourse ## Destroy concourse and its network
	@bin/delete_concourse_network.sh

destroy_concourse: require_vars ## Destroy concourse only
	@bin/delete_concourse.sh

decode_aws_error:
	@aws sts decode-authorization-message --encoded-message ${DECODE_MESSAGE} | jq -r .DecodedMessage | jq .
