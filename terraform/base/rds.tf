resource "aws_db_subnet_group" "rds" {
  name        = "${var.environment}-rds-subnet-group"
  description = "RDS subnet group"
  subnet_ids  = ["${aws_subnet.rds.*.id}"]
}