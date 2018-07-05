data "aws_security_group" "jumpbox_outbound" {
  id = "${var.jumpbox_security_group_id}"
}

resource "aws_security_group" "bosh" {
  name        = "${var.environment}_bosh_security_group"
  description = "Bosh access"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-bosh-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "bosh_mbus_concourse" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 6868
  to_port                  = 6868
  source_security_group_id = "${var.concourse_security_group_id}"
}

resource "aws_security_group_rule" "bosh_uaa_concourse" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8443
  to_port                  = 8443
  source_security_group_id = "${var.concourse_security_group_id}"
}

resource "aws_security_group_rule" "bosh_uaa_jumpbox" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8443
  to_port                  = 8443
  source_security_group_id = "${var.jumpbox_security_group_id}"
}

resource "aws_security_group_rule" "bosh_ssh_concourse" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${var.concourse_security_group_id}"
}

resource "aws_security_group_rule" "bosh_ssh_jumpbox" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${var.jumpbox_security_group_id}"
}

resource "aws_security_group_rule" "bosh_director_concourse" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 25555
  to_port                  = 25555
  source_security_group_id = "${var.concourse_security_group_id}"
}

resource "aws_security_group_rule" "bosh_director_jumpbox" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 25555
  to_port                  = 25555
  source_security_group_id = "${var.jumpbox_security_group_id}"
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

resource "aws_security_group_rule" "jumpbox_uaa_bosh" {
  security_group_id        = "${var.jumpbox_security_group_id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8443
  to_port                  = 8443
  source_security_group_id = "${aws_security_group.bosh.id}"
}

resource "aws_security_group_rule" "jumpbox_ssh_bosh" {
  security_group_id        = "${var.jumpbox_security_group_id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${aws_security_group.bosh.id}"
}

resource "aws_security_group_rule" "jumpbox_director_bosh" {
  security_group_id        = "${var.jumpbox_security_group_id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 25555
  to_port                  = 25555
  source_security_group_id = "${aws_security_group.bosh.id}"
}

resource "aws_security_group" "bosh_rds" {
  name        = "${var.environment}_bosh_rds_security_group"
  description = "BOSH rds access"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-bosh-rds-security-group"
    Environment = "${var.environment}"
  }
}
