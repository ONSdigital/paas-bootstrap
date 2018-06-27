provider "mysql" {
  endpoint = "${var.cf_db_endpoint}"
  username = "${var.cf_db_username}"
  password = "${var.cf_rds_password}"
}

resource "mysql_database" "uaa" {
  name = "uaa"
}

resource "mysql_database" "cc" {
  name = "cc"
}

resource "mysql_database" "bbs" {
  name = "bbs"
}

resource "mysql_database" "routing_api" {
  name = "routing_api"
}

resource "mysql_database" "policy_server" {
  name = "policy_server"
}

resource "mysql_database" "silk_controller" {
  name = "silk_controller"
}

resource "mysql_database" "locket" {
  name = "locket"
}
