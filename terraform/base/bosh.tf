# DNS
resource "aws_route53_record" "bosh_director" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "bosh_director.${aws_route53_zone.private.name}"
  type    = "A"
  ttl     = "30"

  records = ["${local.bosh_private_ip}"]
}

#IAM

resource "aws_iam_instance_profile" "bosh" {
  name = "${var.environment}_bosh_profile"
  role = "${aws_iam_role.bosh.name}"
}

resource "aws_iam_role" "bosh" {
  name = "${var.environment}_bosh_role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "template_file" "iam_policy" {
  template = "${file("${path.module}/templates/bosh_iam_policy.json")}"

  vars {
    environment = "${var.environment}"
    region      = "${var.region}"
    account_id  = "${local.account_id}"
  }
}

resource "aws_iam_role_policy" "bosh" {
  name = "${var.environment}_bosh_policy"
  role = "${aws_iam_role.bosh.id}"

  policy = "${data.template_file.iam_policy.rendered}"
}

# S3

resource "aws_s3_bucket" "bosh_blobstore" {
  bucket = "${var.s3_prefix}-${var.environment}-bosh-blobstore"
  acl    = "private"

  tags {
    Name        = "${var.s3_prefix}-${var.environment}-bosh-blobstore"
    Environment = "${var.environment}"
  }
}

# SG
resource "aws_security_group_rule" "allow-all" {
  security_group_id = "${aws_security_group.bosh.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "bosh" {
  name        = "${var.environment}_bosh_security_group"
  description = "Bosh access"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-bosh-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "bosh_uaa_concourse" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8443
  to_port                  = 8443
  source_security_group_id = "${aws_security_group.concourse.id}"
}

resource "aws_security_group_rule" "bosh_mbus_jumpbox" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 6868
  to_port                  = 6868
  source_security_group_id = "${aws_security_group.jumpbox.id}"
}

resource "aws_security_group_rule" "bosh_uaa_jumpbox" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8443
  to_port                  = 8443
  source_security_group_id = "${aws_security_group.jumpbox.id}"
}

resource "aws_security_group_rule" "bosh_ssh_jumpbox" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${aws_security_group.jumpbox.id}"
}

resource "aws_security_group_rule" "bosh_credhub_jumpbox" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8844
  to_port                  = 8844
  source_security_group_id = "${aws_security_group.jumpbox.id}"
}

resource "aws_security_group_rule" "bosh_credhub_concourse" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8844
  to_port                  = 8844
  source_security_group_id = "${aws_security_group.concourse.id}"
}

resource "aws_security_group_rule" "bosh_director_jumpbox" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 25555
  to_port                  = 25555
  source_security_group_id = "${aws_security_group.jumpbox.id}"
}

resource "aws_security_group_rule" "bosh_management_tcp" {
  security_group_id = "${aws_security_group.bosh.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  self              = true
}

resource "aws_security_group_rule" "bosh_management_udp" {
  security_group_id = "${aws_security_group.bosh.id}"
  type              = "ingress"
  protocol          = "udp"
  from_port         = 0
  to_port           = 65535
  self              = true
}

resource "aws_security_group_rule" "jumpbox_uaa_bosh" {
  security_group_id        = "${aws_security_group.jumpbox.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8443
  to_port                  = 8443
  source_security_group_id = "${aws_security_group.bosh.id}"
}

resource "aws_security_group_rule" "jumpbox_ssh_bosh" {
  security_group_id        = "${aws_security_group.jumpbox.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${aws_security_group.bosh.id}"
}

resource "aws_security_group_rule" "jumpbox_director_bosh" {
  security_group_id        = "${aws_security_group.jumpbox.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 25555
  to_port                  = 25555
  source_security_group_id = "${aws_security_group.bosh.id}"
}

resource "aws_security_group" "bosh_rds" {
  name        = "${var.environment}_bosh_rds_security_group"
  description = "BOSH rds access"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-bosh-rds-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "allow_postgres_from_concourse" {
  security_group_id        = "${aws_security_group.bosh_rds.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.bosh_rds_port}"
  to_port                  = "${var.bosh_rds_port}"
  source_security_group_id = "${aws_security_group.concourse.id}"
  description              = "Provide ingress PostgreSQL traffic from Concourse"
}

resource "aws_security_group_rule" "allow_postgres_from_bosh" {
  security_group_id        = "${aws_security_group.bosh_rds.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.bosh_rds_port}"
  to_port                  = "${var.bosh_rds_port}"
  source_security_group_id = "${aws_security_group.bosh.id}"
  description              = "Provide ingress PostgreSQL traffic from BOSH"
}

resource "aws_security_group_rule" "allow_postgres_from_jumpbox" {
  security_group_id        = "${aws_security_group.bosh_rds.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.bosh_rds_port}"
  to_port                  = "${var.bosh_rds_port}"
  source_security_group_id = "${aws_security_group.jumpbox.id}"
  description              = "Provide ingress PostgreSQL traffic from jumpbox"
}

# BOSH default key pair
resource "tls_private_key" "bosh" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "aws_key_pair" "bosh" {
  key_name   = "${var.environment}-bosh"
  public_key = "${tls_private_key.bosh.public_key_openssh}"
}

resource "aws_security_group" "bosh_managed" {
  name        = "${var.environment}_bosh_managed_security_group"
  description = "Allow BOSH to manage this EC2 instance"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-bosh-managed-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "bosh_to_managed_ssh" {
  security_group_id        = "${aws_security_group.bosh_managed.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${aws_security_group.bosh.id}"
  description              = "Allow BOSH to SSH to instance"
}

resource "aws_security_group_rule" "bosh_to_managed_mbus" {
  security_group_id        = "${aws_security_group.bosh_managed.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 6868
  to_port                  = 6868
  source_security_group_id = "${aws_security_group.bosh.id}"
  description              = "Allow BOSH to access the BOSH agent on instance"
}

resource "aws_security_group_rule" "managed_to_bosh_tcp" {
  security_group_id        = "${aws_security_group.bosh_managed.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.bosh.id}"
  description              = "Allow managed instance to respond to BOSH"
}

resource "aws_security_group_rule" "managed_to_bosh_udp" {
  security_group_id        = "${aws_security_group.bosh_managed.id}"
  type                     = "egress"
  protocol                 = "udp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.bosh.id}"
  description              = "Allow managed instance to respond to BOSH"
}

resource "aws_security_group_rule" "bosh_from_managed_tcp" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.bosh_managed.id}"
  description              = "Allow managed instance to respond to BOSH"
}

resource "aws_security_group_rule" "s3_and_stuff_from_managed" {
  security_group_id = "${aws_security_group.bosh_managed.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow managed instance to hit S3 for blobs and stuff (FIXME: narrow scope)"
}

resource "aws_security_group_rule" "bosh_from_managed" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.bosh_managed.id}"
  description              = "Allow managed instance to respond to BOSH"
}
