output "vpc_dns_nameserver" {
  value = "${cidrhost(aws_vpc.default.cidr_block, 2)}"
}

output "domain" {
  value = "${local.domain}"
}

output "bosh_rds_security_group_id" {
    value = "${aws_security_group.bosh_rds.id}"
}

output "rds_db_subnet_group_id" {
    value = "${aws_db_subnet_group.rds.id}"
}

output "jumpbox_private_key" {
    value = "${tls_private_key.jumpbox.private_key_pem}"
}

output "jumpbox_public_ip" {
  value = "${aws_instance.jumpbox.public_ip}"
}

output "bosh_private_ip" {
  value = "${local.bosh_private_ip}"
}

output "bosh_subnet_cidr_block" {
  value = "${local.bosh_subnet_cidr_block}"
}

output "bosh_subnet_id" {
    value = "${local.bosh_subnet_id}"
}

output "bosh_gateway_ip" {
  value = "${local.bosh_gateway_ip}"
}

output "bosh_director_fqdn" {
    # FIXME: DNS entry
    value = "${local.bosh_private_ip}"
}

output "bosh_iam_instance_profile" {
  value = "${aws_iam_instance_profile.bosh.name}"
}

output "bosh_key_name" {
    value = "${aws_key_pair.bosh.key_name}"
}

output "bosh_security_group_ids" {
    value = [ "${aws_security_group.bosh.id}"]
}

output "bosh_private_key" {
    value = "${tls_private_key.bosh.private_key_pem}"
}

output "cf_rds_security_group_id" {
  value = "${aws_security_group.cf_rds.id}"
}

# NASTY HACK ALERT - we cannot find a way in terraform to perform an action on all elements of a list
#                    so you will have to change this if you add more AZs
output "internal_subnet_gateway_ips" {
  value = [
      "${cidrhost(aws_subnet.internal.*.cidr_block[0],1)}",
      "${cidrhost(aws_subnet.internal.*.cidr_block[1],1)}",
      "${cidrhost(aws_subnet.internal.*.cidr_block[2],1)}"
  ]
}

# NASTY HACK ALERT - we cannot find a way in terraform to perform an action on all elements of a list
#                    so you will have to change this if you add more AZs
output "internal_subnet_reserved_cidr_blocks" {
  value = [
      "${cidrsubnet(aws_subnet.internal.*.cidr_block[0],7,0)}",
      "${cidrsubnet(aws_subnet.internal.*.cidr_block[1],7,0)}",
      "${cidrsubnet(aws_subnet.internal.*.cidr_block[2],7,0)}"
  ]
}

output "internal_subnet_ids" {
    value = ["${aws_subnet.internal.*.id}"]
}

output "internal_subnet_cidr_blocks" {
    value = ["${aws_subnet.internal.*.cidr_block}"]
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

output "cf_ssh_internal_security_group_id" {
  value = "${aws_security_group.cf_ssh_internal.id}"
}

output "cf_ssh_lb_name" {
  value = "${aws_elb.cf-ssh-lb.name}"
}

output "cf_s3_iam_instance_profile" {
  value = "${aws_iam_instance_profile.s3_blobstore.name}"
}

output "cf_rds_client_security_group_id" {
  value = "${aws_security_group.cf_rds_client.id}"
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
output "cf_blobstore_s3_kms_key_id" {
  value = "${aws_kms_key.cf_blobstore_key.id}"
}

output "cf_blobstore_s3_kms_key_arn" {
  value = "${aws_kms_key.cf_blobstore_key.arn}"
}

output "prometheus_subnet_gateway_ips" {
  value = [
      "${cidrhost(aws_subnet.prometheus.*.cidr_block[0],1)}",
      "${cidrhost(aws_subnet.prometheus.*.cidr_block[1],1)}",
      "${cidrhost(aws_subnet.prometheus.*.cidr_block[2],1)}"
  ]
}

# NASTY HACK ALERT - we cannot find a way in terraform to perform an action on all elements of a list
#                    so you will have to change this if you add more AZs
output "prometheus_subnet_reserved_cidr_blocks" {
  value = [
      "${cidrsubnet(aws_subnet.prometheus.*.cidr_block[0],6,0)}",
      "${cidrsubnet(aws_subnet.prometheus.*.cidr_block[1],6,0)}",
      "${cidrsubnet(aws_subnet.prometheus.*.cidr_block[2],6,0)}"
  ]
}

output "prometheus_subnet_ids" {
    value = ["${aws_subnet.prometheus.*.id}"]
}

output "prometheus_subnet_cidr_blocks" {
    value = ["${aws_subnet.prometheus.*.cidr_block}"]
}


output "prometheus_security_group_id" {
  value = "${aws_security_group.prometheus.id}"
}

output "grafana_target_group_name" {
  value = "${aws_lb_target_group.grafana.name}"
}

output "prometheus_target_group_name" {
  value = "${aws_lb_target_group.prometheus.name}"
}

output "alertmanager_target_group_name" {
  value = "${aws_lb_target_group.alertmanager.name}"
}

output "grafana_fqdn" {
  value = "${aws_route53_record.grafana.name}"
}

output "prometheus_fqdn" {
  value = "${aws_route53_record.prometheus.fqdn}"
}

output "alertmanager_fqdn" {
  value = "${aws_route53_record.alertmanager.fqdn}"
}

output "cf_traffic_controller_port" {
  value = "${aws_lb_listener.cf_4443.port}"
}