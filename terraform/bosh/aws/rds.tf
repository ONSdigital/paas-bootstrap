resource "random_string" "bosh_rds_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "bosh_rds" {
  identifier                = "${var.environment}-bosh-rds"
  allocated_storage         = "100"
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.m4.xlarge"
  username                  = "bosh_admin"
  password                  = "${random_string.bosh_rds_password.result}"
  vpc_security_group_ids    = ["${aws_security_group.bosh_rds.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.bosh_rds.id}"
  apply_immediately         = true
  backup_window             = "02:00-03:00"
  maintenance_window        = "Tue:02:15-Tue:04:15"
  copy_tags_to_snapshot     = true
  final_snapshot_identifier = "${var.environment}-bosh-rds-final"
  multi_az                  = true
  storage_encrypted         = true
  storage_type              = "gp2"
  skip_final_snapshot       = true
  option_group_name         = "${aws_db_option_group.bosh_rds_audit_logging.name}"

  tags {
    Name        = "${var.environment}-bosh-rds"
    Environment = "${var.environment}"
  }
}

resource "aws_db_subnet_group" "bosh_rds" {
  name        = "${var.environment}-bosh-rds-subnet-group"
  description = "BOSH rds subnet group"
  subnet_ids  = ["${aws_subnet.rds_az1.id}", "${aws_subnet.rds_az2.id}", "${aws_subnet.rds_az3.id}"]
}

resource "aws_db_option_group" "bosh_rds_audit_logging" {
  name                     = "${var.environment}-bosh-rds-audit-logging"
  option_group_description = "Terraform RDS audit Option group"
  engine_name              = "mysql"
  major_engine_version     = "5.7"

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"

    option_settings {
      name  = "SERVER_AUDIT_EVENTS"
      value = "CONNECT"
    }
  }
}
