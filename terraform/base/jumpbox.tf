# SG
resource "aws_security_group" "jumpbox" {
  name        = "${var.environment}_jumpbox_security_group"
  description = "Jumpbox security group"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-jumpbox-security-group"
    Environment = "${var.environment}"
  }
}
resource "aws_security_group_rule" "jumpbox_ssh" {
  security_group_id = "${aws_security_group.jumpbox.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = "${var.ingress_whitelist}"
}

resource "aws_security_group_rule" "allow_jumpbox_to_postgres" {
  security_group_id        = "${aws_security_group.jumpbox.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.bosh_rds_port}"
  to_port                  = "${var.bosh_rds_port}"
  source_security_group_id = "${aws_security_group.bosh_rds.id}"
  description              = "Provide egress PostgreSQL traffic from jumpbox"
}

resource "aws_security_group_rule" "allow_jumpbox_to_mysql" {
  security_group_id        = "${aws_security_group.jumpbox.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.cf_rds_port}"
  to_port                  = "${var.cf_rds_port}"
  source_security_group_id = "${aws_security_group.cf_rds.id}"
  description              = "Provide egress MySQL traffic from jumpbox"
}

resource "aws_security_group_rule" "allow_jumpbox_to_the_world" {
  security_group_id        = "${aws_security_group.jumpbox.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port = "0"
  to_port = "65535"
  cidr_blocks              = ["0.0.0.0/0"]
  description              = "Sod it, let jumpbox see the world"
}

resource "aws_security_group_rule" "jumpbox_to_managed_ssh" {
  security_group_id        = "${aws_security_group.bosh_managed.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${aws_security_group.jumpbox.id}"
  description              = "Allow Jumpbox to SSH to instance"
}

# SSH
resource "tls_private_key" "jumpbox" {
  algorithm   = "RSA"
  rsa_bits = "2048"
}

resource "aws_key_pair" "jumpbox" {
  key_name = "${var.environment}-jumpbox"
  public_key = "${tls_private_key.jumpbox.public_key_openssh}"
}
# instance
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "jumpbox" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.jumpbox.key_name}"
  subnet_id = "${aws_subnet.public.0.id}"
  vpc_security_group_ids = ["${aws_security_group.jumpbox.id}"]
  user_data = "${data.template_cloudinit_config.jumpbox.rendered}"

  tags {
    Name        = "${var.environment}-jumpbox"
    Environment = "${var.environment}"
  }
}

resource "aws_eip" "jumpbox" {
  instance = "${aws_instance.jumpbox.id}"
  vpc      = true
}

data "template_file" "jumpbox_cloudinit" {
  template = "${file("${path.module}/templates/jumpbox_init.cfg")}"
}

data "template_cloudinit_config" "jumpbox" {

  gzip = false
  base64_encode = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.jumpbox_cloudinit.rendered}"
  }
}