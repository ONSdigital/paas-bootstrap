provider "mysql" {
  endpoint = "${var.cf_db_endpoint}"
  username = "${var.cf_db_username}"
  password = "${var.cf_rds_password}"
}

resource "mysql_database" "foo" {
  name = "foo"
}
