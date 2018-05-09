resource "aws_security_group" "bosh" {
  name        = "${var.environment}_bosh_security_group"
  description = "Bosh access"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-bosh-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "bosh_mbus" {
  security_group_id = "${aws_security_group.bosh.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 6868
  to_port           = 6868
  cidr_blocks       = ["${var.jumpbox_ip}/32", "${var.concourse_ip}/32"]
}

resource "aws_security_group_rule" "bosh_uaa" {
  security_group_id = "${aws_security_group.bosh.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8443
  to_port           = 8443
  cidr_blocks       = ["${var.jumpbox_ip}/32", "${var.concourse_ip}/32"]
}

resource "aws_security_group_rule" "bosh_ssh" {
  security_group_id = "${aws_security_group.bosh.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["${var.jumpbox_ip}/32", "${var.concourse_ip}/32"]
}

resource "aws_security_group_rule" "bosh_director" {
  security_group_id = "${aws_security_group.bosh.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 25555
  to_port           = 25555
  cidr_blocks       = ["${var.jumpbox_ip}/32", "${var.concourse_ip}/32"]
}

resource "aws_security_group_rule" "bosh_management_tcp" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.bosh.id}"
}

resource "aws_security_group_rule" "bosh_management_udp" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.bosh.id}"
}
