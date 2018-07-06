provider "postgresql" {
  host     = "${var.bosh_db_host}"
  username = "${var.bosh_db_username}"
  password = "${var.bosh_rds_password}"

  # sslmode         = "require"
}

resource "postgresql_database" "bosh" {
  name = "bosh"
}
