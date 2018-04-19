resource "aws_internet_gateway" "default" {
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "${var.environment_name}"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${var.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "default" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "10.0.1.0/24"
  tags {
    Name = "${var.environment_name}"
  }
}

resource "aws_security_group" "default" {
  name        = "${var.environment_name}_concourse_elb_security_group"
  description = "Concourse public access"
  vpc_id      = "${var.vpc_id}"
  tags {
    Name = "${var.environment_name}"
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 6868
      to_port     = 6868
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "atc" {
    vpc = true
    tags {
        Name = "${var.environment_name}"
    }
    depends_on = ["aws_internet_gateway.default"]
}

resource "aws_key_pair" "default" {
    key_name = "${var.environment_name}_default_ssh_key"
    public_key = "${var.public_key}"
}