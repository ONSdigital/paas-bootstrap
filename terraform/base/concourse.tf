# SG
resource "aws_security_group" "concourse" {
  name        = "${var.environment}_concourse_security_group"
  description = "Concourse public access"
  vpc_id      = "${aws_vpc.default.id}"

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
  source_security_group_id = "${aws_security_group.concourse_alb.id}"
}

resource "aws_security_group_rule" "concourse_bosh_director" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 25555
  to_port                  = 25555
  description              = "Allow concourse to access bosh director"
  source_security_group_id = "${aws_security_group.concourse.id}"
}

resource "aws_security_group_rule" "concourse_from_bosh_rule_tcp_ssh" {
  security_group_id        = "${aws_security_group.concourse.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${aws_security_group.bosh.id}"
}

resource "aws_security_group_rule" "concourse_from_bosh_rule_tcp_bosh_agent" {
  security_group_id        = "${aws_security_group.concourse.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 6868
  to_port                  = 6868
  source_security_group_id = "${aws_security_group.bosh.id}"
}

resource "aws_security_group_rule" "concourse_from_jumpbox_rule_tcp_ssh" {
  security_group_id        = "${aws_security_group.concourse.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${aws_security_group.jumpbox.id}"
}

resource "aws_security_group_rule" "bosh_ssh_concourse" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${aws_security_group.concourse.id}"
}

resource "aws_security_group_rule" "bosh_mbus_concourse" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 6868
  to_port                  = 6868
  source_security_group_id = "${aws_security_group.concourse.id}"
}

resource "aws_security_group_rule" "bosh_tcp_from_concourse" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.concourse.id}"
}

resource "aws_security_group_rule" "bosh_udp_from_concourse" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.concourse.id}"
}

resource "aws_security_group_rule" "jumpbox_ssh_concourse" {
  security_group_id        = "${aws_security_group.jumpbox.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${aws_security_group.concourse.id}"
}

resource "aws_security_group_rule" "concourse_outbound" {
  security_group_id = "${aws_security_group.concourse.id}"
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "concourse_rule_tcp" {
  security_group_id = "${aws_security_group.concourse.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  self              = true
}

resource "aws_security_group_rule" "concourse_rule_udp" {
  security_group_id = "${aws_security_group.concourse.id}"
  type              = "ingress"
  protocol          = "udp"
  from_port         = 0
  to_port           = 65535
  self              = true
}

resource "aws_security_group_rule" "concourse_rule_icmp" {
  security_group_id = "${aws_security_group.concourse.id}"
  type              = "ingress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  self              = true
}

resource "aws_security_group" "concourse_alb" {
  name        = "${var.environment}_concourse_alb_security_group"
  description = "Concourse public access"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-concourse-alb-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "concourse_alb_https" {
  security_group_id = "${aws_security_group.concourse_alb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["${local.loadbalancer_whitelist}"]
}

resource "aws_security_group_rule" "concourse_alb_to_web" {
  security_group_id        = "${aws_security_group.concourse_alb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = "${aws_security_group.concourse.id}"
}


# IP
resource "aws_eip" "concourse" {
  vpc = true
}

# Load Balancer
resource "aws_lb" "concourse" {
  name                             = "${var.environment}-concourse-alb"
  subnets                          = ["${aws_subnet.public.*.id}"]
  security_groups                  = ["${aws_security_group.concourse_alb.id}"]
  load_balancer_type               = "application"
  internal                         = false
  enable_cross_zone_load_balancing = true

  tags {
    Name        = "${var.environment}-concourse-alb"
    Environment = "${var.environment}"
  }
}

resource "aws_lb_listener" "concourse" {
  load_balancer_arn = "${aws_lb.concourse.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_acm_certificate.concourse.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.concourse.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "concourse" {
  name     = "${var.environment}-concourse-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 5
  }

  tags {
    Name        = "${var.environment}-concourse-target-group"
    Environment = "${var.environment}"
  }
}

# Certificate
resource "aws_acm_certificate" "concourse" {
  domain_name       = "ci.${local.domain}"
  validation_method = "DNS"

  tags {
    Name        = "${var.environment}-ci-cert"
    Environment = "${var.environment}"
  }
}

resource "aws_route53_record" "concourse_validation" {
  name    = "${aws_acm_certificate.concourse.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.concourse.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.child_zone.zone_id}"
  records = ["${aws_acm_certificate.concourse.domain_validation_options.0.resource_record_value}"]
  ttl     = 30
}

resource "aws_acm_certificate_validation" "concourse" {
  certificate_arn         = "${aws_acm_certificate.concourse.arn}"
  validation_record_fqdns = ["${aws_route53_record.concourse_validation.fqdn}"]
}

# DNS
resource "aws_route53_record" "concourse" {
  zone_id = "${aws_route53_zone.child_zone.zone_id}"
  name    = "ci.${local.domain}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_lb.concourse.dns_name}"]
}
