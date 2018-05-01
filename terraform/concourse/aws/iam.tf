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
    s3_kms_key_arn = "${var.s3_kms_key_arn}"
    environment    = "${var.environment}"
  }
}

resource "aws_iam_role_policy" "concourse" {
  name = "${var.environment}_concourse_policy"
  role = "${aws_iam_role.concourse.id}"

  policy = "${data.template_file.iam_policy.rendered}"
}
