resource "aws_security_group" "concourse" {
  name        = "${var.environment}_concourse_security_group"
  description = "Concourse public access"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-concourse-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "concourse_web" {
  security_group_id        = "${aws_security_group.concourse.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = "${aws_security_group.alb.id}"
}

resource "aws_security_group_rule" "concourse_ssh" {
  security_group_id = "${aws_security_group.concourse.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = "${var.ingress_whitelist}"
}

resource "aws_security_group_rule" "concourse_mbus" {
  security_group_id = "${aws_security_group.concourse.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 6868
  to_port           = 6868
  cidr_blocks       = "${var.ingress_whitelist}"
}

resource "aws_security_group_rule" "concourse_outbound" {
  security_group_id = "${aws_security_group.concourse.id}"
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "alb" {
  name        = "${var.environment}_concourse_alb_security_group"
  description = "Concourse public access"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-concourse-alb-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "concourse_alb_https" {
  security_group_id = "${aws_security_group.alb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = "${var.ingress_whitelist}"
}

resource "aws_security_group_rule" "concourse_alb_to_web" {
  security_group_id        = "${aws_security_group.alb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = "${aws_security_group.concourse.id}"
}
