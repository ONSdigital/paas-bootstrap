resource "aws_internet_gateway" "default" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.environment}"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${var.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "default" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.az}"

  tags {
    Name        = "${var.environment}-default-subnet"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "default" {
  name        = "${var.environment}_default_security_group"
  description = "Concourse public access"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-default-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "concourse_web" {
  security_group_id        = "${aws_security_group.default.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = "${aws_security_group.elb.id}"
}

resource "aws_security_group_rule" "concourse_ssh" {
  security_group_id = "${aws_security_group.default.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = "${var.ingress_whitelist}"
}

resource "aws_security_group_rule" "concourse_mbus" {
  security_group_id = "${aws_security_group.default.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 6868
  to_port           = 6868
  cidr_blocks       = "${var.ingress_whitelist}"
}

resource "aws_security_group_rule" "concourse_outbound" {
  security_group_id = "${aws_security_group.default.id}"
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_eip" "atc" {
  vpc = true

  tags {
    Name        = "${var.environment}-atc-eip"
    Environment = "${var.environment}"
  }

  depends_on = ["aws_internet_gateway.default"]
}

resource "aws_key_pair" "default" {
  key_name   = "${var.environment}_default_ssh_key"
  public_key = "${var.public_key}"
}
