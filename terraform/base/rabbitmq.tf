resource "aws_security_group" "rabbitmq_broker" {
  name        = "${var.environment}_rabbitmq_broker_security_group"
  description = "RabbitMQ service broker access"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-rabbitmq-broker-security-group"
    Environment = "${var.environment}"
  }
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