help:
	@echo "Sorry, no help here"

vpc:
	@bin/create_vpc.sh

concourse_network: vpc
	@bin/create_concourse_network.sh

