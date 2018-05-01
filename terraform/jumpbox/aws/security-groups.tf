resource "aws_security_group" "jumpbox" {
  name        = "${var.environment}_jumpbox_security_group"
  description = "Jumpbox security group"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-jumpbox-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "jumpbox_ssh" {
  security_group_id = "${aws_security_group.jumpbox.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = "${var.ingress_whitelist}"
}

resource "aws_security_group_rule" "jumpbox_internal_access" {
  security_group_id = "${aws_security_group.jumpbox.id}"
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["10.0.0.0/16"]
}
