locals {
  account_id = "${data.aws_caller_identity.current.account_id}"
  domain = "${replace(aws_route53_zone.child_zone.name, "/\\.$/", "")}"
  num_azs = "${length(var.availability_zones)}"
  public_subnets = "${var.cidr_blocks["public"]}"
  internal_subnets = "${var.cidr_blocks["internal"]}"
  services_subnets = "${var.cidr_blocks["services"]}"
  rds_subnets = "${var.cidr_blocks["rds"]}"
  prometheus_subnets = "${var.cidr_blocks["prometheus"]}"
  bosh_subnet_id = "${aws_subnet.internal.*.id[var.bosh_availability_zone_index]}"

  bosh_subnet_cidr_block = "${aws_subnet.internal.*.cidr_block[var.bosh_availability_zone_index]}"
  bosh_private_ip = "${cidrhost(aws_subnet.internal.*.cidr_block[var.bosh_availability_zone_index], 6)}"
  bosh_gateway_ip = "${cidrhost(aws_subnet.internal.*.cidr_block[var.bosh_availability_zone_index], 1)}"
  loadbalancer_whitelist = ["${concat(var.ingress_whitelist,formatlist("%s/32", concat(list(aws_eip.concourse.public_ip), aws_nat_gateway.nat.*.public_ip)))}"]
}
