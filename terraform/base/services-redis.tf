# Redis (Elasticache)
resource "aws_security_group" "redis" {
  name        = "${var.environment}_redis_security_group"
  description = "Redis access"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-redis-security-group"
    Environment = "${var.environment}"
  }
}

# resource "aws_security_group_rule" "allow-all" {
#   security_group_id = "${aws_security_group.bosh.id}"
#   type              = "egress"
#   protocol          = "-1"
#   from_port         = 0
#   to_port           = 0
#   cidr_blocks       = ["0.0.0.0/0"]
# }

# CREATE USER


resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = ["${aws_subnet.rds.*.id}"]
}

resource "aws_elasticache_security_group" "redis" {
  name                 = "${var.environment}-redis-security-group"
  security_group_names = ["${aws_security_group.redis.name}"]
}