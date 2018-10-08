locals {
    account_id = "${data.aws_caller_identity.current.account_id}"
    domain = "${replace(aws_route53_zone.child_zone.name, "/\\.$/", "")}"
    num_azs = "${length(var.availability_zones)}"
    services_subnets = "${var.cidr_blocks["services"]}"
}