locals {
    num_azs = "${length(var.availability_zones)}"
    services_subnets = "${var.services_cidr_block}"
}