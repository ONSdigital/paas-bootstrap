resource "random_string" "cf_rds_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "cf_rds" {
  identifier                = "${var.environment}-cf-rds"
  allocated_storage         = "100"
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.m4.xlarge"
  username                  = "cf_admin"
  password                  = "${random_string.cf_rds_password.result}"
  vpc_security_group_ids    = ["${aws_security_group.cf_rds.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.cf_rds.id}"
  apply_immediately         = true
  backup_window             = "01:00-02:00"
  maintenance_window        = "Mon:02:15-Mon:04:15"
  copy_tags_to_snapshot     = true
  final_snapshot_identifier = "${var.environment}-cf-rds-final"
  multi_az                  = true
  storage_encrypted         = true
  storage_type              = "gp2"
  skip_final_snapshot       = true
  option_group_name         = "${aws_db_option_group.cf_rds_audit_logging.name}"
  name                      = "paastest"

  tags {
    Name        = "${var.environment}-cf-rds"
    Environment = "${var.environment}"
  }
}

resource "aws_db_subnet_group" "cf_rds" {
  name        = "${var.environment}-cf-rds-subnet-group"
  description = "CF rds subnet group"
  subnet_ids  = ["${aws_subnet.rds_az1.id}", "${aws_subnet.rds_az2.id}", "${aws_subnet.rds_az3.id}"]
}

resource "aws_db_option_group" "cf_rds_audit_logging" {
  name                     = "${var.environment}-cf-rds-audit-logging"
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
