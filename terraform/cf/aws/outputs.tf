output "cf_internal_subnet_az1_id" {
  value = "${aws_subnet.az1.id}"
}

output "cf_internal_subnet_az2_id" {
  value = "${aws_subnet.az2.id}"
}

output "cf_internal_subnet_az3_id" {
  value = "${aws_subnet.az3.id}"
}

output "cf_internal_subnet_az1_cidr" {
  value = "${aws_subnet.az1.cidr_block}"
}

output "cf_internal_subnet_az2_cidr" {
  value = "${aws_subnet.az2.cidr_block}"
}

output "cf_internal_subnet_az3_cidr" {
  value = "${aws_subnet.az3.cidr_block}"
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
  value = "${aws_elb.cf-ssh-lb.name}"
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

output "cf_db_username" {
  value = "${aws_db_instance.cf_rds.username}"
}

output "cf_db_type" {
  value = "${aws_db_instance.cf_rds.engine}"
}

output "cf_db_port" {
  value = "${aws_db_instance.cf_rds.port}"
}

output "cf_rds_fqdn" {
  value = "${aws_route53_record.cf_rds.fqdn}"
}

output "cf_db_endpoint" {
  value = "${aws_db_instance.cf_rds.endpoint}"
}

output "cf_rds_password" {
  value = "${random_string.cf_rds_password.result}"
}

output "cf_rds_client_security_group_id" {
  value = "${aws_security_group.cf_rds_client.id}"
}

output "cf_traffic_controller_port" {
  value = "${aws_lb_listener.cf_4443.port}"
}

output "cf_dummy_db" {
  value = "${aws_db_instance.cf_rds.name}"
}

output "services_subnet_gateway_ips" {
  value = [
      "${cidrhost(aws_subnet.services.*.cidr_block[0],1)}",
      "${cidrhost(aws_subnet.services.*.cidr_block[1],1)}",
      "${cidrhost(aws_subnet.services.*.cidr_block[2],1)}"
  ]
}

# NASTY HACK ALERT - we cannot find a way in terraform to perform an action on all elements of a list
#                    so you will have to change this if you add more AZs
output "services_subnet_reserved_cidr_blocks" {
  value = [
      "${cidrsubnet(aws_subnet.services.*.cidr_block[0],7,0)}",
      "${cidrsubnet(aws_subnet.services.*.cidr_block[1],7,0)}",
      "${cidrsubnet(aws_subnet.services.*.cidr_block[2],7,0)}"
  ]
}

output "services_subnet_ids" {
    value = ["${aws_subnet.services.*.id}"]
}

output "services_subnet_cidr_blocks" {
    value = ["${aws_subnet.services.*.cidr_block}"]
}

output "rabbitmq_broker_security_group_id" {
  value = "${aws_security_group.rabbitmq_broker.id}"
}

output "rabbitmq_server_security_group_id" {
  value = "${aws_security_group.rabbitmq_server.id}"
}
