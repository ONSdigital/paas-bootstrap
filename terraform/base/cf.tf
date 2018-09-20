# Load Balancers
resource "aws_lb" "cf" {
  name                             = "${var.environment}-cf-alb"
  subnets                          = ["${aws_subnet.public.*.id}"]
  security_groups                  = ["${aws_security_group.cf_alb.id}"]
  load_balancer_type               = "application"
  internal                         = false
  enable_cross_zone_load_balancing = true

  tags {
    Name        = "${var.environment}-cf-alb"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "cf_443" {
  depends_on        = ["aws_acm_certificate_validation.cf"]
  load_balancer_arn = "${aws_lb.cf.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_acm_certificate.cf.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.cf.arn}"
    type             = "forward"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "cf_4443" {
  depends_on        = ["aws_acm_certificate_validation.cf"]
  load_balancer_arn = "${aws_lb.cf.arn}"
  port              = "4443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_acm_certificate.cf.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.cf.arn}"
    type             = "forward"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "cf" {
  name     = "${var.environment}-cf-target-group"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = "${aws_vpc.default.id}"

  health_check {
    path                = "/health"
    port                = 8080
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 5
  }

  tags {
    Name        = "${var.environment}-cf-target-group"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "cf-ssh-lb" {
  name                      = "${var.environment}-cf-ssh-lb"
  internal                  = false
  subnets                   = ["${aws_subnet.public.*.id}"]
  cross_zone_load_balancing = "true"

  security_groups = ["${aws_security_group.cf_ssh_lb.id}"]

  health_check {
    target              = "TCP:2222"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }

  listener {
    instance_port     = 2222
    instance_protocol = "tcp"
    lb_port           = 2222
    lb_protocol       = "tcp"
  }

  tags {
    Name        = "${var.environment}-cf-ssh-lb"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
# Certificates
resource "aws_acm_certificate" "cf" {
  domain_name               = "${var.environment}.${var.parent_dns_zone}"
  validation_method         = "DNS"
  subject_alternative_names = ["*.system.${var.environment}.${var.parent_dns_zone}", "*.apps.${var.environment}.${var.parent_dns_zone}"]

  tags {
    Name        = "${var.environment}-cf-system-cert"
    Environment = "${var.environment}"
  }
}

resource "aws_route53_record" "cf_validation" {
  count = 3

  name    = "${lookup(aws_acm_certificate.cf.domain_validation_options[count.index], "resource_record_name")}"
  type    = "${lookup(aws_acm_certificate.cf.domain_validation_options[count.index], "resource_record_type")}"
  zone_id = "${aws_route53_zone.child_zone.zone_id}"
  records = ["${lookup(aws_acm_certificate.cf.domain_validation_options[count.index], "resource_record_value")}"]
  ttl     = 30
}

resource "aws_acm_certificate_validation" "cf" {
  certificate_arn         = "${aws_acm_certificate.cf.arn}"
  validation_record_fqdns = ["${aws_route53_record.cf_validation.*.fqdn}"]
}

resource "aws_route53_record" "cf_system" {
  zone_id = "${aws_route53_zone.child_zone.zone_id}"
  name    = "*.system.${var.environment}.${var.parent_dns_zone}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_lb.cf.dns_name}"]
}

resource "aws_route53_record" "cf_apps" {
  zone_id = "${aws_route53_zone.child_zone.zone_id}"
  name    = "*.apps.${var.environment}.${var.parent_dns_zone}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_lb.cf.dns_name}"]
}

resource "aws_route53_record" "cf_ssh" {
  zone_id = "${aws_route53_zone.child_zone.zone_id}"
  name    = "ssh.system.${var.environment}.${var.parent_dns_zone}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_elb.cf-ssh-lb.dns_name}"]
}

# Security Group

resource "aws_security_group" "cf_alb" {
  name        = "${var.environment}_cf_alb_security_group"
  description = "CF public access"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-cf-alb-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "cf_alb_https" {
  security_group_id = "${aws_security_group.cf_alb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["${local.loadbalancer_whitelist}"]
  description       = "Whitelist administrator access for HTTPS"
}

resource "aws_security_group_rule" "cf_alb_4443" {
  security_group_id = "${aws_security_group.cf_alb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 4443
  to_port           = 4443
  cidr_blocks       = ["${local.loadbalancer_whitelist}"]
  description       = "Whitelist administrator access for HTTPS/4443"
}

resource "aws_security_group_rule" "cf_alb_egress_internal" {
  security_group_id = "${aws_security_group.cf_alb.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow access to (eventually) internal services"
}

resource "aws_security_group" "internal" {
  name        = "${var.environment}_cf_internal_security_group"
  description = "Internal"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-cf-internal-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "internal_rule_tcp" {
  security_group_id = "${aws_security_group.internal.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  self              = true
}

resource "aws_security_group_rule" "internal_rule_udp" {
  security_group_id = "${aws_security_group.internal.id}"
  type              = "ingress"
  protocol          = "udp"
  from_port         = 0
  to_port           = 65535
  self              = true
}

resource "aws_security_group_rule" "internal_rule_icmp" {
  security_group_id = "${aws_security_group.internal.id}"
  type              = "ingress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  self              = true
}

resource "aws_security_group_rule" "internal_rule_allow_internet" {
  security_group_id = "${aws_security_group.internal.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "cf_router_lb_internal_security_group" {
  name        = "${var.environment}_cf_router_lb_internal_security_group"
  description = "CF Router Internal"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    security_groups = ["${aws_security_group.cf_alb.id}"]
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
  }

  ingress {
    security_groups = ["${aws_security_group.cf_alb.id}"]
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.environment}-cf-router-lb-internal-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "cf_ssh_lb" {
  name        = "${var.environment}_cf_ssh_lb"
  description = "CF SSH traffic from load balancer"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-cf-ssh-lb-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "allow_tcp_2222_from_nat_gateways" {
  security_group_id = "${aws_security_group.cf_ssh_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 2222
  to_port           = 2222
  cidr_blocks       = ["${local.loadbalancer_whitelist}"]
  description       = "Allow SSH proxy traffic from internal components"
}


resource "aws_security_group_rule" "allow_tcp_2222_to_proxies" {
  security_group_id        = "${aws_security_group.cf_ssh_lb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 2222
  to_port                  = 2222
  source_security_group_id = "${aws_security_group.cf_ssh_internal.id}"
  description              = "Provide egress SSH traffic"
}

resource "aws_security_group" "cf_ssh_internal" {
  name        = "${var.environment}_cf_ssh_internal"
  description = "CF SSH internal access"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-cf-ssh-internal-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "allow_tcp_2222_from_ssh_lb" {
  security_group_id        = "${aws_security_group.cf_ssh_internal.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 2222
  to_port                  = 2222
  source_security_group_id = "${aws_security_group.cf_ssh_lb.id}"
  description              = "Provide ingress SSH traffic"
}

resource "aws_security_group" "cf_rds" {
  name        = "${var.environment}_cf_rds_security_group"
  description = "CF rds access"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-cf-rds-security-group"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "allow_mysql_from_concourse" {
  security_group_id        = "${aws_security_group.cf_rds.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = "${aws_security_group.concourse.id}"
  description              = "Provide ingress MySQL traffic from Concourse"
}

resource "aws_security_group_rule" "allow_mysql_from_cf_internal_clients" {
  security_group_id        = "${aws_security_group.cf_rds.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = "${aws_security_group.cf_rds_client.id}"
  description              = "Provide ingress MySQL traffic from CF"
}
resource "aws_security_group_rule" "allow_mysql_from_jumpbox" {
  security_group_id        = "${aws_security_group.cf_rds.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.cf_rds_port}"
  to_port                  = "${var.cf_rds_port}"
  source_security_group_id = "${aws_security_group.jumpbox.id}"
  description              = "Provide ingress MySQL traffic from jumpbox"
}
resource "aws_security_group" "cf_rds_client" {
  name        = "${var.environment}_cf_rds_client_security_group"
  description = "CF rds consumer"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-cf-rds-client-security-group"
    Environment = "${var.environment}"
  }
}


# IAM

resource "aws_iam_instance_profile" "s3_blobstore" {
  name = "${var.environment}_s3_blobstore"
  role = "${aws_iam_role.s3_blobstore.name}"
}

resource "aws_iam_role" "s3_blobstore" {
  name = "${var.environment}_s3_blobstore_role"
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

resource "aws_iam_role_policy" "cloud_controller" {
  name = "${var.environment}_cloud_controller_policy"
  role = "${aws_iam_role.s3_blobstore.id}"

  policy = "${data.template_file.cloud_controller_policy.rendered}"
}

data "template_file" "cloud_controller_policy" {
  template = "${file("${path.module}/templates/cloud_controller_policy.json")}"

  vars {
    environment              = "${var.environment}"
    cf_blobstore_kms_key_arn = "${aws_kms_key.cf_blobstore_key.arn}"
    s3_prefix                = "${var.s3_prefix}"
  }
}

# S3 Blobs
resource "aws_kms_key" "cf_blobstore_key" {
  description             = "This key is used to encrypt CF objects in blobstore"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags {
    Name        = "${var.environment}-cf-blobstore-key"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket" "cf_buildpacks" {
  bucket = "${var.s3_prefix}-${var.environment}-cf-buildpacks"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.cf_blobstore_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags {
    Name        = "${var.s3_prefix}-${var.environment}-cf-buildpacks"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket" "cf_droplets" {
  bucket = "${var.s3_prefix}-${var.environment}-cf-droplets"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.cf_blobstore_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags {
    Name        = "${var.s3_prefix}-${var.environment}-cf-droplets"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket" "cf_packages" {
  bucket = "${var.s3_prefix}-${var.environment}-cf-packages"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.cf_blobstore_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags {
    Name        = "${var.s3_prefix}-${var.environment}-cf-packages"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket" "cf_resource_pool" {
  bucket = "${var.s3_prefix}-${var.environment}-cf-resource-pool"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = false
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.cf_blobstore_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags {
    Name        = "${var.s3_prefix}-${var.environment}-cf-resource-pool"
    Environment = "${var.environment}"
  }
}
