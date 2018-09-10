data "aws_security_group" "bosh" {
  id = "${var.bosh_security_group_id}"
}

data "aws_security_group" "jumpbox" {
  id = "${var.jumpbox_security_group_id}"
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

# Port 80 disabled, see [#157117450]
# resource "aws_security_group_rule" "cf_alb_http" {
#   security_group_id = "${aws_security_group.cf_alb.id}"
#   type              = "ingress"
#   protocol          = "tcp"
#   from_port         = 80
#   to_port           = 80
#   cidr_blocks       = ["${concat(var.ingress_whitelist,formatlist("%s/32", list(var.concourse_public_ip, data.aws_nat_gateway.az1.public_ip, data.aws_nat_gateway.az2.public_ip, data.aws_nat_gateway.az3.public_ip)))}"]
#   description       = "Whitelist administrator access for HTTP"
# }

resource "aws_security_group_rule" "cf_alb_https" {
  security_group_id = "${aws_security_group.cf_alb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["${concat(var.ingress_whitelist,formatlist("%s/32", list(var.concourse_public_ip, data.aws_nat_gateway.az1.public_ip, data.aws_nat_gateway.az2.public_ip, data.aws_nat_gateway.az3.public_ip)))}"]
  description       = "Whitelist administrator access for HTTPS"
}

resource "aws_security_group_rule" "cf_alb_4443" {
  security_group_id = "${aws_security_group.cf_alb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 4443
  to_port           = 4443
  cidr_blocks       = ["${concat(var.ingress_whitelist,formatlist("%s/32", list(var.concourse_public_ip, data.aws_nat_gateway.az1.public_ip, data.aws_nat_gateway.az2.public_ip, data.aws_nat_gateway.az3.public_ip)))}"]
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

resource "aws_security_group_rule" "internal_to_service_broker_postgres" {
  security_group_id = "${aws_security_group.internal.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
  source_security_group_id = "${aws_security_group.cf_service_brokers.id}"
  description              = "Allow internal to connect to rds service broker"
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

resource "aws_security_group_rule" "cf_from_jumpbox_rule_tcp_ssh" {
  security_group_id        = "${aws_security_group.internal.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${data.aws_security_group.jumpbox.id}"
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

resource "aws_security_group_rule" "bosh_tcp_from_cf" {
  security_group_id        = "${data.aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.internal.id}"
}

resource "aws_security_group_rule" "bosh_udp_from_cf" {
  security_group_id        = "${data.aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.internal.id}"
}

resource "aws_security_group_rule" "jumpbox_ssh_cf" {
  security_group_id        = "${data.aws_security_group.jumpbox.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${aws_security_group.internal.id}"
}

resource "aws_security_group" "cf_router_lb_internal_security_group" {
  name        = "${var.environment}_cf_router_lb_internal_security_group"
  description = "CF Router Internal"
  vpc_id      = "${var.vpc_id}"

  ingress {
    security_groups = ["${aws_security_group.cf_alb.id}"]
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
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

resource "aws_security_group" "cf_ssh_lb" {
  name        = "${var.environment}_cf_ssh_lb"
  description = "CF SSH traffic from load balancer"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-cf-ssh-lb-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "allow_tcp_2222_from_whitelist" {
  security_group_id = "${aws_security_group.cf_ssh_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 2222
  to_port           = 2222
  cidr_blocks       = ["${var.ingress_whitelist}"]
  description       = "Allow SSH proxy traffic from whitelist"
}

resource "aws_security_group_rule" "allow_tcp_2222_from_nat_gateways" {
  security_group_id = "${aws_security_group.cf_ssh_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 2222
  to_port           = 2222
  cidr_blocks       = ["${data.aws_nat_gateway.az1.public_ip}/32", "${data.aws_nat_gateway.az2.public_ip}/32", "${data.aws_nat_gateway.az3.public_ip}/32"]
  description       = "Allow SSH proxy traffic from internal components"
}

resource "aws_security_group_rule" "allow_tcp_2222_from_concourse" {
  security_group_id = "${aws_security_group.cf_ssh_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 2222
  to_port           = 2222
  cidr_blocks       = ["${var.concourse_public_ip}/32"]
  description       = "Allow SSH proxy traffic from Concourse"
}

resource "aws_security_group_rule" "allow_tcp_2222_to_proxies" {
  security_group_id        = "${aws_security_group.cf_ssh_lb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 2222
  to_port                  = 2222
  source_security_group_id = "${aws_security_group.cf_ssh_internal.id}"
  description              = "Provide egress SSH traffic"
}

resource "aws_security_group" "cf_ssh_internal" {
  name        = "${var.environment}_cf_ssh_internal"
  description = "CF SSH internal access"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-cf-ssh-internal-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "allow_tcp_2222_from_ssh_lb" {
  security_group_id        = "${aws_security_group.cf_ssh_internal.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 2222
  to_port                  = 2222
  source_security_group_id = "${aws_security_group.cf_ssh_lb.id}"
  description              = "Provide ingress SSH traffic"
}

resource "aws_security_group" "cf_rds" {
  name        = "${var.environment}_cf_rds_security_group"
  description = "CF rds access"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-cf-rds-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "allow_mysql_from_concourse" {
  security_group_id        = "${aws_security_group.cf_rds.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = "${var.concourse_security_group_id}"
  description              = "Provide ingress MySQL traffic from Concourse"
}

resource "aws_security_group_rule" "allow_mysql_from_cf_internal_clients" {
  security_group_id        = "${aws_security_group.cf_rds.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = "${aws_security_group.cf_rds_client.id}"
  description              = "Provide ingress MySQL traffic from CF"
}

resource "aws_security_group" "cf_rds_client" {
  name        = "${var.environment}_cf_rds_client_security_group"
  description = "CF rds consumer"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-cf-rds-client-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "cf_service_brokers" {
  name        = "${var.environment}_cf_service_brokers_security_group"
  description = "CF service brokers access"
  vpc_id      = "${var.vpc_id}"
   tags {
    Name        = "${var.environment}-cf-service-brokers-security-group"
    Environment = "${var.environment}"
  }
}
 resource "aws_security_group_rule" "allow_postgres_from_cf_internal_clients" {
  security_group_id        = "${aws_security_group.cf_service_brokers.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
  source_security_group_id = "${aws_security_group.internal.id}"
  description              = "Provide ingress service broker postgres traffic from CF"
}
