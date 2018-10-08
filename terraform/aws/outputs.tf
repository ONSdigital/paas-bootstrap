output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "vpc_dns_nameserver" {
  value = "${cidrhost(aws_vpc.default.cidr_block, 2)}"
}

output "region" {
  value = "${var.region}"
}

output "az1" {
  value = "${var.az1}"
}

output "az2" {
  value = "${var.az2}"
}

output "az3" {
  value = "${var.az3}"
}

output "default_route_table_id" {
  value = "${aws_vpc.default.main_route_table_id}"
}

output "environment" {
  value = "${var.environment}"
}

output "ingress_whitelist" {
  value = "${var.ingress_whitelist}"
}

output "s3_kms_key_id" {
  value = "${aws_kms_key.paas_state_key.id}"
}

output "s3_kms_key_arn" {
  value = "${aws_kms_key.paas_state_key.arn}"
}

output "dns_zone" {
  value = "${aws_route53_zone.child_zone.name}"
}

output "parent_dns_zone" {
  value = "${var.parent_dns_zone}"
}

output "state_bucket_id" {
  value = "${aws_s3_bucket.paas_states.id}"
}

output "aws_internet_gateway_id" {
  value = "${aws_internet_gateway.default.id}"
}

output "s3_prefix" {
  value = "${var.s3_prefix}"
}

output "private_dns_zone" {
  value = "${aws_route53_zone.private.name}"
}
