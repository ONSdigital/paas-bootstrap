output "bosh_rds_security_group_id" {
    value = "${aws_security_group.bosh_rds.id}"
}

output "rds_db_subnet_group_id" {
    value = "${aws_db_subnet_group.rds.id}"
}