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
