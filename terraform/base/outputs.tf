output "vpc_dns_nameserver" {
  value = "${cidrhost(aws_vpc.default.cidr_block, 2)}"
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

