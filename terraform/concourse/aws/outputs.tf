output "default_security_groups" {
  value = ["${aws_security_group.default.id}"]
}

output "internal_cidr" {
  value = "${aws_subnet.az1.cidr_block}"
}

output "internal_gw" {
  value = "${var.default_gw_ip}"
}

output "internal_ip" {
  value = "${var.concourse_ip}"
}

output "public_ip" {
  value = "${aws_eip.atc.public_ip}"
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

output "default_key_name" {
  value = "${aws_key_pair.default.key_name}"
}

output "concourse_fqdn" {
  value = "${aws_route53_record.concourse.name}"
}

output "concourse_direct_fqdn" {
  value = "${aws_route53_record.concourse_direct.name}"
}

output "concourse_alb_target_group" {
  value = "${aws_lb_target_group.concourse.name}"
}

output "concourse_iam_instance_profile" {
  value = "${aws_iam_instance_profile.concourse.name}"
}

output "s3_kms_key_id" {
  value = "${var.s3_kms_key_id}"
}

output "s3_kms_key_arn" {
  value = "${var.s3_kms_key_arn}"
}

output "state_bucket_id" {
  value = "${var.state_bucket_id}"
}
