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
    region     = "${var.region}"
    account_id = "${local.account_id}"
  }
}

resource "aws_iam_role_policy" "bosh" {
  name = "${var.environment}_bosh_policy"
  role = "${aws_iam_role.bosh.id}"

  policy = "${data.template_file.iam_policy.rendered}"
}

# S3
resource "aws_s3_bucket_object" "bosh-var-store" {
  bucket                 = "${aws_s3_bucket.paas_states.id}"
  acl                    = "private"
  key                    = "bosh/bosh-variables.yml"
  source                 = "/dev/null"
  server_side_encryption = "aws:kms"
  kms_key_id             = "${aws_kms_key.paas_state_key.arn}"
}

resource "aws_s3_bucket_object" "bosh-state" {
  bucket                 = "${aws_s3_bucket.paas_states.id}"
  acl                    = "private"
  key                    = "bosh/bosh-state.json"
  content                = "{}"
  server_side_encryption = "aws:kms"
  kms_key_id             = "${aws_kms_key.paas_state_key.arn}"
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

resource "aws_security_group_rule" "bosh_mbus_concourse" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 6868
  to_port                  = 6868
  source_security_group_id = "${aws_security_group.concourse.id}"
}

resource "aws_security_group_rule" "bosh_uaa_concourse" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8443
  to_port                  = 8443
  source_security_group_id = "${aws_security_group.concourse.id}"
}

resource "aws_security_group_rule" "bosh_uaa_jumpbox" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8443
  to_port                  = 8443
  source_security_group_id = "${aws_security_group.jumpbox.id}"
}

resource "aws_security_group_rule" "bosh_ssh_concourse" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${aws_security_group.concourse.id}"
}

resource "aws_security_group_rule" "bosh_ssh_jumpbox" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${aws_security_group.jumpbox.id}"
}

resource "aws_security_group_rule" "bosh_director_concourse" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 25555
  to_port                  = 25555
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
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.bosh.id}"
}

resource "aws_security_group_rule" "bosh_management_udp" {
  security_group_id        = "${aws_security_group.bosh.id}"
  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.bosh.id}"
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