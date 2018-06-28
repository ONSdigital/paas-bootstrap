resource "aws_db_instance" "cf_rds" {
  identifier             = "${var.environment}-cf-rds"
  allocated_storage      = "100"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.m4.xlarge"
  username               = "cf_admin"
  password               = "${var.cf_rds_password}"
  vpc_security_group_ids = ["${aws_security_group.cf_rds.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.cf_rds.id}"
  apply_immediately      = "true"
  backup_window          = "01:00-02:00"
  maintenance_window     = "Mon:02:15-Mon:04:15"
  copy_tags_to_snapshot  = "true"
  kms_key_id             = "${aws_kms_key.cf_rds_key.arn}"
  multi_az               = "true"
  storage_encrypted      = "true"
  storage_type           = "gp2"

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

resource "aws_kms_key" "cf_rds_key" {
  description             = "This key is used to encrypt the CF RDS databases"
  deletion_window_in_days = 7
}
