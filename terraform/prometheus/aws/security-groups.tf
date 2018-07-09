data "aws_security_group" "bosh" {
  id = "${var.bosh_security_group_id}"
}

data "aws_security_group" "cf" {
  id = "${var.cf_internal_security_group_id}"
}

resource "aws_security_group" "prometheus" {
  name        = "${var.environment}_prometheus_security_group"
  description = "Prometheus node exporter access"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-prometheus-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "prometheus_bosh_node_exporters" {
  security_group_id        = "${data.aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9190
  to_port                  = 9190
  description              = "Allow prometheus to access bosh node exporter"
  source_security_group_id = "${aws_security_group.prometheus.id}"
}

resource "aws_security_group_rule" "prometheus_cf_node_exporters" {
  security_group_id        = "${data.aws_security_group.cf.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9190
  to_port                  = 9190
  description              = "Allow prometheus to access cf node exporter"
  source_security_group_id = "${aws_security_group.prometheus.id}"
}

resource "aws_security_group_rule" "prometheus_bosh_director" {
  security_group_id        = "${data.aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 25555
  to_port                  = 25555
  description              = "Allow prometheus to access bosh director"
  source_security_group_id = "${aws_security_group.prometheus.id}"
}

resource "aws_security_group_rule" "prometheus_bosh_ssh" {
  security_group_id        = "${aws_security_group.prometheus.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  description              = "Allow bosh to access prometheus ssh"
  source_security_group_id = "${data.aws_security_group.bosh.id}"
}

resource "aws_security_group_rule" "prometheus_bosh_mbus" {
  security_group_id        = "${aws_security_group.prometheus.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 6868
  to_port                  = 6868
  description              = "Allow bosh to access prometheus mbus"
  source_security_group_id = "${data.aws_security_group.bosh.id}"
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

resource "aws_security_group_rule" "grafana_web_access" {
  security_group_id = "${aws_security_group.prometheus.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3000
  to_port           = 3000
  cidr_blocks       = "${var.ingress_whitelist}"
}
