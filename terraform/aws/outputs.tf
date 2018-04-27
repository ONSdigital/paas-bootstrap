output "vpc_id" {
  value = "${aws_vpc.default.id}"
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
