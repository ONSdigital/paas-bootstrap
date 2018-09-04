data "aws_caller_identity" "current" {}

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
