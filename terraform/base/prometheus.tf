# Load balancing

resource "aws_lb" "prometheus" {
  name                             = "${var.environment}-prometheus-alb"
  subnets                          = ["${aws_subnet.public.*.id}"]
  security_groups                  = ["${aws_security_group.prometheus_alb.id}"]
  load_balancer_type               = "application"
  internal                         = false
  enable_cross_zone_load_balancing = true

  tags {
    Name        = "${var.environment}-prometheus-alb"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "prometheus_443" {
  depends_on        = ["aws_acm_certificate_validation.prometheus"]
  load_balancer_arn = "${aws_lb.prometheus.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_acm_certificate.prometheus.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.grafana.arn}"
    type             = "forward"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "grafana" {
  name                 = "${var.environment}-grafana-target-group"
  port                 = 3000
  protocol             = "HTTP"
  vpc_id               = "${aws_vpc.default.id}"
  deregistration_delay = "30"

  tags {
    Name        = "${var.environment}-grafana-target-group"
    Environment = "${var.environment}"
  }

  health_check {
    path                = "/metrics"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 5
  }
}

resource "aws_lb_target_group" "prometheus" {
  name                 = "${var.environment}-prometheus-target-group"
  port                 = 9090
  protocol             = "HTTP"
  vpc_id               = "${aws_vpc.default.id}"
  deregistration_delay = "30"

  tags {
    Name        = "${var.environment}-prometheus-target-group"
    Environment = "${var.environment}"
  }

  health_check {
    path                = "/login"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 5
    matcher             = "401"
  }
}

resource "aws_lb_listener_rule" "prometheus_host_routing" {
  listener_arn = "${aws_lb_listener.prometheus_443.arn}"
  priority     = 4

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.prometheus.arn}"
  }

  condition {
    field  = "host-header"
    values = ["prometheus.*"]
  }
}

resource "aws_lb_target_group" "alertmanager" {
  name                 = "${var.environment}-alertmgr-target-group"
  port                 = 9093
  protocol             = "HTTP"
  vpc_id               = "${aws_vpc.default.id}"
  deregistration_delay = "30"

  tags {
    Name        = "${var.environment}-alertmgr-target-group"
    Environment = "${var.environment}"
  }

  health_check {
    path                = "/login"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 5
    matcher             = "401"
  }
}

resource "aws_lb_listener_rule" "alertmanager_host_routing" {
  listener_arn = "${aws_lb_listener.prometheus_443.arn}"
  priority     = 6

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.alertmanager.arn}"
  }

  condition {
    field  = "host-header"
    values = ["alertmanager.*"]
  }
}

# Certificates

resource "aws_acm_certificate" "prometheus" {
  domain_name = "*.prometheus.${local.domain}"

  subject_alternative_names = [
    "prometheus.${local.domain}",
    "grafana.${local.domain}",
    "alertmanager.${local.domain}"
  ]

  validation_method = "DNS"

  tags {
    Name        = "${var.environment}-prometheus-cert"
    Environment = "${var.environment}"
  }
}

resource "aws_route53_record" "prometheus_validation" {
  count = 4

  name    = "${lookup(aws_acm_certificate.prometheus.domain_validation_options[count.index], "resource_record_name")}"
  type    = "${lookup(aws_acm_certificate.prometheus.domain_validation_options[count.index], "resource_record_type")}"
  zone_id = "${aws_route53_zone.child_zone.zone_id}"
  records = ["${lookup(aws_acm_certificate.prometheus.domain_validation_options[count.index], "resource_record_value")}"]
  ttl     = 30
}

resource "aws_acm_certificate_validation" "prometheus" {
  certificate_arn         = "${aws_acm_certificate.prometheus.arn}"
  validation_record_fqdns = ["${aws_route53_record.prometheus_validation.*.fqdn}"]
}

# DNS

resource "aws_route53_record" "prometheus" {
  zone_id = "${aws_route53_zone.child_zone.zone_id}"
  name    = "prometheus.${local.domain}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_lb.prometheus.dns_name}"]
}

resource "aws_route53_record" "grafana" {
  zone_id = "${aws_route53_zone.child_zone.zone_id}"
  name    = "grafana.${local.domain}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_lb.prometheus.dns_name}"]
}

resource "aws_route53_record" "alertmanager" {
  zone_id = "${aws_route53_zone.child_zone.zone_id}"
  name    = "alertmanager.${local.domain}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_lb.prometheus.dns_name}"]
}

# S3

# resource "aws_s3_bucket_object" "prometheus-var-store" {
#   bucket                 = "${aws_s3_bucket.paas_states.id}"
#   acl                    = "private"
#   key                    = "prometheus/prometheus-variables.yml"
#   source                 = "/dev/null"
#   server_side_encryption = "aws:kms"
#   kms_key_id             = "${var.s3_kms_key_arn}"
# }

# Security groups

resource "aws_security_group" "prometheus" {
  name        = "${var.environment}_prometheus_security_group"
  description = "Prometheus node exporter access"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-prometheus-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "prometheus_bosh_data_exporters" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9190
  to_port                  = 9190
  description              = "Allow prometheus to access bosh data exporter"
  source_security_group_id = "${aws_security_group.prometheus.id}"
}

resource "aws_security_group_rule" "prometheus_bosh_node_exporters" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9100
  to_port                  = 9100
  description              = "Allow prometheus to access bosh node exporter"
  source_security_group_id = "${aws_security_group.prometheus.id}"
}

resource "aws_security_group_rule" "managed_node_exporters" {
  security_group_id        = "${aws_security_group.bosh_managed.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9100
  to_port                  = 9100
  source_security_group_id = "${aws_security_group.prometheus.id}"
  description              = "Allow BOSH to access the BOSH agent on instance"
}



resource "aws_security_group_rule" "prometheus_cf_nats" {
  security_group_id        = "${aws_security_group.internal.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 4222
  to_port                  = 4222
  description              = "Allow prometheus to access cf nats"
  source_security_group_id = "${aws_security_group.prometheus.id}"
}

resource "aws_security_group_rule" "prometheus_bosh_director" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 25555
  to_port                  = 25555
  description              = "Allow prometheus to access bosh director"
  source_security_group_id = "${aws_security_group.prometheus.id}"
}

resource "aws_security_group_rule" "prometheus_outbound" {
  security_group_id = "${aws_security_group.prometheus.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  description       = "Allow prometheus to access everything"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prometheus_rule_tcp" {
  security_group_id = "${aws_security_group.prometheus.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  self              = true
}

resource "aws_security_group_rule" "prometheus_rule_udp" {
  security_group_id = "${aws_security_group.prometheus.id}"
  type              = "ingress"
  protocol          = "udp"
  from_port         = 0
  to_port           = 65535
  self              = true
}

resource "aws_security_group_rule" "prometheus_rule_icmp" {
  security_group_id = "${aws_security_group.prometheus.id}"
  type              = "ingress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  self              = true
}

resource "aws_security_group" "prometheus_alb" {
  name        = "${var.environment}_prometheus_alb_security_group"
  description = "Prometheus web access"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-prometheus-alb-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "prometheus_alb_web_access" {
  security_group_id = "${aws_security_group.prometheus_alb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["${local.loadbalancer_whitelist}"]
  description       = "External access to Prometheus service"
}

resource "aws_security_group_rule" "prometheus_alb_to_grafana_access" {
  security_group_id        = "${aws_security_group.prometheus_alb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3000
  to_port                  = 3000
  source_security_group_id = "${aws_security_group.prometheus.id}"
  description              = "Route traffic to Grafana"
}

resource "aws_security_group_rule" "grafana_from_prometheus_alb_access" {
  security_group_id        = "${aws_security_group.prometheus.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3000
  to_port                  = 3000
  source_security_group_id = "${aws_security_group.prometheus_alb.id}"
  description              = "Access to Grafana"
}

resource "aws_security_group_rule" "prometheus_alb_to_prometheus_access" {
  security_group_id        = "${aws_security_group.prometheus_alb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 9090
  to_port                  = 9090
  source_security_group_id = "${aws_security_group.prometheus.id}"
  description              = "Route traffic to Prometheus"
}

resource "aws_security_group_rule" "prometheus_alb_access" {
  security_group_id        = "${aws_security_group.prometheus.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9090
  to_port                  = 9090
  source_security_group_id = "${aws_security_group.prometheus_alb.id}"
  description              = "Access to Prometheus"
}

resource "aws_security_group_rule" "prometheus_alb_to_alertmanager_access" {
  security_group_id        = "${aws_security_group.prometheus_alb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 9093
  to_port                  = 9093
  source_security_group_id = "${aws_security_group.prometheus.id}"
  description              = "Route traffic to Alertmanager"
}

resource "aws_security_group_rule" "alertmanager_alb_access" {
  security_group_id        = "${aws_security_group.prometheus.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9093
  to_port                  = 9093
  source_security_group_id = "${aws_security_group.prometheus_alb.id}"
  description              = "Access to Alertmanager"
}

