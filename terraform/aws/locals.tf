locals {
  account_id = "${data.aws_caller_identity.current.account_id}"
  num_azs = "${length(var.availability_zones)}"
  public_subnets = "${var.cidr_blocks["public"]}"
  internal_subnets = "${var.cidr_blocks["internal"]}"
  services_subnets = "${var.cidr_blocks["services"]}"
  rds_subnets = "${var.cidr_blocks["rds"]}"
  bosh_private_ip = "${cidrhost(local.public_subnets[0], 6)}"
}
