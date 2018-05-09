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
  template = "${file("${path.module}/templates/iam_policy.json")}"

  vars {
    region = "${var.region}"
  }
}

resource "aws_iam_role_policy" "bosh" {
  name = "${var.environment}_bosh_policy"
  role = "${aws_iam_role.bosh.id}"

  policy = "${data.template_file.iam_policy.rendered}"
}
