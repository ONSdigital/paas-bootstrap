data "aws_security_group" "bosh" {
  id = "${var.bosh_security_group_id}"
}

resource "aws_security_group" "cf_alb" {
  name        = "${var.environment}_cf_alb_security_group"
  description = "CF public access"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-cf-alb-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "cf_alb_http" {
  security_group_id = "${aws_security_group.cf_alb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["${concat(var.ingress_whitelist,formatlist("%s/32", list(var.public_ip, data.aws_nat_gateway.selected.public_ip)))}"]
  description       = "Whitelist administrator access for HTTP"
}

resource "aws_security_group_rule" "cf_alb_https" {
  security_group_id = "${aws_security_group.cf_alb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["${concat(var.ingress_whitelist,formatlist("%s/32", list(var.public_ip, data.aws_nat_gateway.selected.public_ip)))}"]
  description       = "Whitelist administrator access for HTTPS"
}

resource "aws_security_group_rule" "cf_alb_4443" {
  security_group_id = "${aws_security_group.cf_alb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 4443
  to_port           = 4443
  cidr_blocks       = ["${concat(var.ingress_whitelist,formatlist("%s/32", list(var.public_ip, data.aws_nat_gateway.selected.public_ip)))}"]
  description       = "Whitelist administrator access for HTTPS/4443"
}

resource "aws_security_group_rule" "cf_alb_egress_internal" {
  security_group_id = "${aws_security_group.cf_alb.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow access to (eventually) internal services"
}

# resource "aws_security_group_rule" "cf_alb_internal" {
#   security_group_id        = "${aws_security_group.cf_alb.id}"
#   type                     = "egress"
#   protocol                 = "-1"
#   from_port                = 0
#   to_port                  = 0
#   source_security_group_id = "${aws_security_group.internal.id}"
#   description              = "Allow access to internal services"
# }

resource "aws_security_group" "internal" {
  name        = "${var.environment}_cf_internal_security_group"
  description = "Internal"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-cf-internal-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "internal_rule_tcp" {
  security_group_id = "${aws_security_group.internal.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  self              = true
}

resource "aws_security_group_rule" "internal_rule_udp" {
  security_group_id = "${aws_security_group.internal.id}"
  type              = "ingress"
  protocol          = "udp"
  from_port         = 0
  to_port           = 65535
  self              = true
}

resource "aws_security_group_rule" "internal_rule_icmp" {
  security_group_id = "${aws_security_group.internal.id}"
  type              = "ingress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  self              = true
}

resource "aws_security_group_rule" "internal_rule_allow_internet" {
  security_group_id = "${aws_security_group.internal.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "cf_from_bosh_rule_tcp_ssh" {
  security_group_id        = "${aws_security_group.internal.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${data.aws_security_group.bosh.id}"
}

resource "aws_security_group_rule" "cf_from_bosh_rule_tcp_bosh_agent" {
  security_group_id        = "${aws_security_group.internal.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 6868
  to_port                  = 6868
  source_security_group_id = "${data.aws_security_group.bosh.id}"
}

resource "aws_security_group_rule" "bosh_ssh_cf" {
  security_group_id        = "${data.aws_security_group.bosh.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${aws_security_group.internal.id}"
}

resource "aws_security_group_rule" "bosh_mbus_cf" {
  security_group_id        = "${data.aws_security_group.bosh.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 6868
  to_port                  = 6868
  source_security_group_id = "${aws_security_group.internal.id}"
}

resource "aws_security_group" "cf_router_lb_internal_security_group" {
  name        = "${var.environment}_cf_router_lb_internal_security_group"
  description = "CF Router Internal"
  vpc_id      = "${var.vpc_id}"

  ingress {
    security_groups = ["${aws_security_group.cf_alb.id}"]
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
  }

  ingress {
    security_groups = ["${aws_security_group.cf_alb.id}"]
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.environment}-cf-router-lb-internal-security-group"
    Environment = "${var.environment}"
  }
}
