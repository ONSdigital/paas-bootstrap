output "default_security_groups" {
  value = ["${aws_security_group.concourse.id}"]
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

output "concourse_public_ip" {
  value = "${aws_eip.atc.public_ip}"
}

# All of the concourse deployment YMLs refer to the Concourse IP as "public_ip"
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

output "concourse_security_group_id" {
  value = "${aws_security_group.concourse.id}"
}

output "nat_az1_id" {
  value = "${aws_nat_gateway.nat_az1.id}"
}

output "nat_az1_private_ip" {
  value = "${aws_nat_gateway.nat_az1.private_ip}"
}

output "nat_az2_id" {
  value = "${aws_nat_gateway.nat_az2.id}"
}

output "nat_az2_private_ip" {
  value = "${aws_nat_gateway.nat_az2.private_ip}"
}

output "nat_az3_id" {
  value = "${aws_nat_gateway.nat_az3.id}"
}

output "nat_az3_private_ip" {
  value = "${aws_nat_gateway.nat_az3.private_ip}"
}

output "concourse_role" {
  value = "${aws_iam_role_policy.concourse.role}"
}

output "vpc_dns_nameserver" {
  value = "${var.vpc_dns_nameserver}"
}