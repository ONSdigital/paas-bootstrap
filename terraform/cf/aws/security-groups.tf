resource "aws_security_group" "cf_alb" {
  name        = "${var.environment}_cf_alb_security_group"
  description = "CF public access"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-cf-alb-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "cf_alb_https" {
  security_group_id = "${aws_security_group.cf_alb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = "${var.ingress_whitelist}"
}
