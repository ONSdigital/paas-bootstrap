data "aws_caller_identity" "current" {}

data "aws_kms_key" "default_s3" {
  key_id = "alias/aws/s3"
}

resource "aws_iam_instance_profile" "concourse" {
  name = "${var.environment}_concourse_profile"
  role = "${aws_iam_role.concourse.name}"
}

resource "aws_iam_role" "concourse" {
  name = "${var.environment}_concourse_role"
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
  template = "${file("${path.module}/templates/iam_policy.json")}"

  vars {
    s3_kms_key_arn         = "${var.s3_kms_key_arn}"
    default_s3_kms_key_arn = "${data.aws_kms_key.default_s3.arn}"
    environment            = "${var.environment}"
    hosted_zone_id         = "${data.aws_route53_zone.child_zone.zone_id}"
    parent_hosted_zone_id  = "${data.aws_route53_zone.parent.zone_id}"
    region                 = "${var.region}"
    account_id             = "${data.aws_caller_identity.current.account_id}"
    vpc_arn                = "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc/${var.vpc_id}"
    subnet_arn             = "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/${aws_subnet.az1.id}"
  }
}

resource "aws_iam_role_policy" "concourse" {
  name = "${var.environment}_concourse_policy"
  role = "${aws_iam_role.concourse.id}"

  policy = "${data.template_file.iam_policy.rendered}"
}
