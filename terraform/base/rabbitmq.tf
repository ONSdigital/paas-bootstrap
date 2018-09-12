resource "aws_security_group" "rabbitmq_broker" {
  name        = "${var.environment}_rabbitmq_broker_security_group"
  description = "RabbitMQ service broker access"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-rabbitmq-broker-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "cf_to_rmq_broker" {
  security_group_id        = "${aws_security_group.rabbitmq_broker.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 4567
  to_port                  = 4567
  source_security_group_id = "${aws_security_group.internal.id}"
  description              = "CF may talk to RabbitMQ broker API"
}

resource "aws_security_group_rule" "rmq_broker_outbound" {
  security_group_id        = "${aws_security_group.rabbitmq_broker.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  cidr_blocks              = ["0.0.0.0/0"] # FIXME: restrict to the CF ALB security group - 443, 8443
  description              = "RabbitMQ broker outbound access"
}

resource "aws_security_group_rule" "rmq_broker_self_tcp" {
  security_group_id        = "${aws_security_group.rabbitmq_broker.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  self                     = true
  description              = "RabbitMQ broker self TCP"
}

resource "aws_security_group_rule" "rmq_broker_self_udp" {
  security_group_id        = "${aws_security_group.rabbitmq_broker.id}"
  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 0
  to_port                  = 65535
  self                     = true
  description              = "RabbitMQ broker self UDP"
}

resource "aws_security_group_rule" "rmq_broker_self_icmp" {
  security_group_id        = "${aws_security_group.rabbitmq_broker.id}"
  type                     = "ingress"
  protocol                 = "icmp"
  from_port                = -1
  to_port                  = -1
  self                     = true
  description              = "RabbitMQ broker self ICMP"
}

resource "aws_security_group_rule" "rabbitmq_to_cf_nats" {
  security_group_id        = "${aws_security_group.internal.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 4222
  to_port                  = 4222
  description              = "Allow rabbitmq broker to access cf nats"
  source_security_group_id = "${aws_security_group.rabbitmq_broker.id}"
}

resource "aws_security_group_rule" "cf_to_rmq_5671_2" {
  security_group_id        = "${aws_security_group.rabbitmq_broker.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 5671
  to_port                  = 5672
  source_security_group_id = "${aws_security_group.internal.id}"
  description              = "CF may talk to RabbitMQ on ports 5671,2"
}

resource "aws_security_group_rule" "cf_to_rmq_1883" {
  security_group_id        = "${aws_security_group.rabbitmq_broker.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 1883
  to_port                  = 1883
  source_security_group_id = "${aws_security_group.internal.id}"
  description              = "CF may talk to RabbitMQ on ports 5671,2"
}

resource "aws_security_group_rule" "cf_to_rmq_8883" {
  security_group_id        = "${aws_security_group.rabbitmq_broker.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8883
  to_port                  = 8883
  source_security_group_id = "${aws_security_group.internal.id}"
  description              = "CF may talk to RabbitMQ on ports 8883"
}

resource "aws_security_group_rule" "cf_to_rmq_61613_4" {
  security_group_id        = "${aws_security_group.rabbitmq_broker.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 61613
  to_port                  = 61614
  source_security_group_id = "${aws_security_group.internal.id}"
  description              = "CF may talk to RabbitMQ on ports 61613,4"
}

resource "aws_security_group_rule" "cf_to_rmq_15672" {
  security_group_id        = "${aws_security_group.rabbitmq_broker.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 15672
  to_port                  = 15672
  source_security_group_id = "${aws_security_group.internal.id}"
  description              = "CF may talk to RabbitMQ on ports 15672"
}

resource "aws_security_group_rule" "cf_to_rmq_15674" {
  security_group_id        = "${aws_security_group.rabbitmq_broker.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 15674
  to_port                  = 15674
  source_security_group_id = "${aws_security_group.internal.id}"
  description              = "CF may talk to RabbitMQ on ports 15674"
}



resource "aws_security_group" "rabbitmq_server" {
  name        = "${var.environment}_rabbitmq_server_security_group"
  description = "RabbitMQ server access"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-rabbitmq-server-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "rmq_server_self_tcp" {
  security_group_id        = "${aws_security_group.rabbitmq_server.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  self                     = true
  description              = "RabbitMQ broker self TCP"
}

resource "aws_security_group_rule" "rmq_server_self_udo" {
  security_group_id        = "${aws_security_group.rabbitmq_server.id}"
  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 0
  to_port                  = 65535
  self                     = true
  description              = "RabbitMQ broker self UDP"
}

resource "aws_security_group_rule" "rmq_server_self_icmp" {
  security_group_id        = "${aws_security_group.rabbitmq_server.id}"
  type                     = "ingress"
  protocol                 = "icmp"
  from_port                = -1
  to_port                  = -1
  self                     = true
  description              = "RabbitMQ server self ICMP"
}

resource "aws_security_group_rule" "rmq_broker_to_rmq_server" {
  security_group_id        = "${aws_security_group.rabbitmq_server.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.rabbitmq_broker.id}"
  description              = "RabbitMQ broker can do everything to the servers"
}


