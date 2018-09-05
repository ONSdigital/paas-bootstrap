output "bosh_db_type" {
  value = "${aws_db_instance.bosh_rds.engine}"
}

output "bosh_rds_fqdn" {
  value = "${aws_db_instance.bosh_rds.address}"
}
output "bosh_db_host" {
  value = "${aws_db_instance.bosh_rds.address}"
}

output "bosh_db_port" {
  value = "${aws_db_instance.bosh_rds.port}"
}

output "bosh_db_engine_version" {
  value = "${aws_db_instance.bosh_rds.engine_version}"
}

output "bosh_db_username" {
  value = "${aws_db_instance.bosh_rds.username}"
}

output "bosh_rds_password" {
  value = "${random_string.bosh_rds_password.result}"
}