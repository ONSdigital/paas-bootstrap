provider "mysql" {
  endpoint = "${var.bosh_db_endpoint}"
  username = "${var.bosh_db_username}"
  password = "${var.bosh_rds_password}"
}

resource "mysql_database" "foo" {
  name = "foo"
}
