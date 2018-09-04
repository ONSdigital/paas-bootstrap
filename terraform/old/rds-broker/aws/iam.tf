data "aws_caller_identity" "current" {}

resource "aws_iam_user" "rds_broker" {
  name = "${var.environment}_rds_broker"
}

resource "aws_iam_access_key" "rds_broker" {
  user = "${aws_iam_user.rds_broker.name}"
}

resource "aws_iam_user_policy_attachment" "rds_broker_attach" {
  user       = "${aws_iam_user.rds_broker.name}"
  policy_arn = "${aws_iam_policy.rds_broker.arn}"
}

resource "aws_iam_role" "rds_broker" {
  name = "${var.environment}_rds_broker_role"

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

resource "aws_iam_policy" "rds_broker" {
  name = "${var.environment}_rds_broker_policy"

  policy = "${data.template_file.iam_policy.rendered}"
}
