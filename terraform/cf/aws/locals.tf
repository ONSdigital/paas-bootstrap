locals {
    domain = "${replace(aws_route53_zone.child_zone.name, "/\\.$/", "")}"
    num_azs = "${length(var.availability_zones)}"
    services_subnets = "${var.services_cidr_block}"
}