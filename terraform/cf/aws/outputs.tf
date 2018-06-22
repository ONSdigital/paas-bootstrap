output "cf_internal_subnet_az1_id" {
  value = "${aws_subnet.az1.id}"
}

output "cf_internal_subnet_az1_cidr" {
  value = "${aws_subnet.az1.cidr_block}"
}

output "cf_internal_security_group_id" {
  value = "${aws_security_group.internal.id}"
}

output "cf_router_target_group_name" {
  value = "${aws_lb_target_group.cf.name}"
}

output "cf_router_lb_internal_security_group_id" {
  value = "${aws_security_group.cf_router_lb_internal_security_group.id}"
}

output "cf_ssh_internal" {
  value = "${aws_security_group.cf_ssh_internal.id}"
}

output "cf_ssh_lb" {
  value = "${aws_elb.cf_ssh_lb.name}"
}

output "cf_blobstore_s3_kms_key_id" {
  value = "${aws_kms_key.cf_blobstore_key.id}"
}

output "cf_blobstore_s3_kms_key_arn" {
  value = "${aws_kms_key.cf_blobstore_key.arn}"
}

output "cf_s3_iam_instance_profile" {
  value = "${aws_iam_instance_profile.s3_blobstore.name}"
}

output "cf_buildpacks_bucket_name" {
  value = "${aws_s3_bucket.cf_buildpacks.id}"
}

output "cf_droplets_bucket_name" {
  value = "${aws_s3_bucket.cf_droplets.id}"
}

output "cf_resource_pool_bucket_name" {
  value = "${aws_s3_bucket.cf_resource_pool.id}"
}

output "cf_packages_bucket_name" {
  value = "${aws_s3_bucket.cf_packages.id}"
}
