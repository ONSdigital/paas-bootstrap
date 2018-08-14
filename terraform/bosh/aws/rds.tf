resource "random_string" "bosh_rds_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "bosh_rds" {
  identifier                = "${var.environment}-bosh-rds"
  allocated_storage         = "100"
  engine                    = "postgres"
  engine_version            = "9.6.8"
  instance_class            = "db.m4.xlarge"
  username                  = "bosh_admin"
  password                  = "${random_string.bosh_rds_password.result}"
  vpc_security_group_ids    = ["${aws_security_group.bosh_rds.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.bosh_rds.id}"
  apply_immediately         = true
  backup_window             = "01:00-02:00"
  maintenance_window        = "Tue:02:15-Tue:04:15"
  copy_tags_to_snapshot     = true
  final_snapshot_identifier = "${var.environment}-bosh-rds-final"
  multi_az                  = true
  storage_encrypted         = true
  storage_type              = "gp2"
  skip_final_snapshot       = true
  name                      = "paastest"

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
