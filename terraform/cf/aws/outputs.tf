output "cf-internal-subnet-az1-id" {
  value = "${aws_subnet.az1.id}"
}

output "cf-internal-subnet-az1-cidr" {
  value = "${aws_subnet.az1.cidr_block}"
}

output "cf-internal-security-group-id" {
  value = "${aws_security_group.internal.id}"
}

output "cf-router-target-group-name" {
  value = "${aws_lb_target_group.cf.name}"
}

output "cf-router-lb-internal-security-group-id" {
  value = "${aws_security_group.cf_router_lb_internal_security_group.id}"
}

output "cf-ssh-internal" {
  value = "${aws_security_group.cf_ssh_internal.id}"
}

output "cf-ssh-lb" {
  value = "${aws_elb.cf-ssh-lb.name}"
}

output "cf_blobstore_s3_kms_key_id" {
  value = "${aws_kms_key.cf-blobstore-key.id}"
}

output "cf_blobstore_s3_kms_key_arn" {
  value = "${aws_kms_key.cf-blobstore-key.arn}"
}

output "cf_s3_iam_instance_profile" {
  value = "${aws_iam_instance_profile.s3_blobstore.name}"
}
