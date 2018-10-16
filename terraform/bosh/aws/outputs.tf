output "default_security_groups" {
  value = ["${aws_security_group.bosh.id}"]
}

output "internal_cidr" {
  value = "${aws_subnet.az1.cidr_block}"
}

output "internal_gw" {
  value = "${var.default_gw_ip}"
}

output "subnet_id" {
  value = "${aws_subnet.az1.id}"
}

output "az" {
  value = "${var.az1}"
}

output "region" {
  value = "${var.region}"
}

output "bosh_iam_instance_profile" {
  value = "${aws_iam_instance_profile.bosh.name}"
}

output "bosh_security_group_id" {
  value = "${aws_security_group.bosh.id}"
}

output "s3_kms_key_id" {
  value = "${var.s3_kms_key_id}"
}

output "s3_kms_key_arn" {
  value = "${var.s3_kms_key_arn}"
}

output "bosh_db_host" {
  value = "${aws_db_instance.bosh_rds.address}"
}

output "bosh_db_username" {
  value = "${aws_db_instance.bosh_rds.username}"
}

output "bosh_dummy_db" {
  value = "${aws_db_instance.bosh_rds.name}"
}

output "bosh_db_type" {
  value = "${aws_db_instance.bosh_rds.engine}"
}

output "bosh_db_engine_version" {
  value = "${aws_db_instance.bosh_rds.engine_version}"
}

output "bosh_db_port" {
  value = "${aws_db_instance.bosh_rds.port}"
}

output "bosh_rds_fqdn" {
  value = "${aws_route53_record.bosh_rds.fqdn}"
}

output "bosh_db_endpoint" {
  value = "${aws_db_instance.bosh_rds.endpoint}"
}

output "bosh_rds_password" {
  value = "${random_string.bosh_rds_password.result}"
}

output "bosh_director_fqdn" {
  value = "${aws_route53_record.bosh_director.fqdn}"
}

output "cidr_blocks" {
  value = "${var.cidr_blocks}"
}
