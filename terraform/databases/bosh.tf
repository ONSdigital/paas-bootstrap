provider "postgresql" {
  alias            = "bosh"
  host             = "${var.bosh_db_host}"
  port             = "${var.bosh_db_port}"
  username         = "${var.bosh_db_username}"
  password         = "${var.bosh_rds_password}"
  expected_version = "${var.bosh_db_engine_version}"  
}

resource "postgresql_database" "bosh" {
  provider = "postgresql.bosh"
  name = "bosh"
}
