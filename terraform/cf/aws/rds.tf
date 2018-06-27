resource "aws_db_instance" "cf_rds" {
  identifier             = "${var.environment}-cf-rds"
  allocated_storage      = "100"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "m4.xlarge"
  username               = "cf_admin"
  password               = "${var.cf_rds_password}"
  vpc_security_group_ids = ["${aws_security_group.cf_rds.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.cf_rds.id}"
}

resource "aws_db_subnet_group" "cf_rds" {
  name        = "${var.environment}-cf-rds-subnet-group"
  description = "CF rds subnet group"
  subnet_ids  = ["${aws_subnet.rds_az1.id}", "${aws_subnet.rds_az2.id}", "${aws_subnet.rds_az3.id}"]
}

provider "mysql" {
  endpoint = "${aws_db_instance.cf_rds.endpoint}"
  username = "${aws_db_instance.cf_rds.username}"
  password = "${aws_db_instance.cf_rds.password}"
}

resource "mysql_database" "foo" {
  depends_on = ["aws_db_instance.cf_rds"]
  name       = "foo"
}
