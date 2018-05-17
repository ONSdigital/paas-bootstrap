resource "aws_security_group" "cf_alb" {
  name        = "${var.environment}_cf_alb_security_group"
  description = "CF public access"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-cf-alb-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "cf_alb_outbound" {
  security_group_id = "${aws_security_group.cf_alb.id}"
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}
