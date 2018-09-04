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

resource "aws_iam_role_policy" "concourse" {
  name = "${var.environment}_concourse_policy"
  role = "${aws_iam_role.concourse.id}"

  policy = "${data.template_file.iam_policy.rendered}"
}
