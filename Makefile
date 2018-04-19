help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

vpc: ## Setup a VPC to deploy concourse to
	@bin/create_vpc.sh

concourse_network: vpc ## Setup networks for concourse to consume
	@bin/create_concourse_network.sh

concourse: concourse_network ## Deploy concourse with all prereqs
	@bin/deploy_concourse.sh


concourse_only: ## Just deploy concourse, skipping terraform
	@bin/deploy_concourse.sh