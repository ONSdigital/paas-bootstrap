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

  policy = <<EOA
{
    "Version": "2012-10-17",
    "Statement": [
     {
       "Effect": "Allow",
       "Action": ["s3:ListBucket", "s3:ListBucketVersions", "s3:GetBucketVersioning"],
       "Resource": ["arn:aws:s3:::${var.environment}-states"]
     },
     {
       "Effect": "Allow",
       "Action": ["s3:ListObject", "s3:GetObject", "s3:GetObjectVersion"],
       "Resource": ["arn:aws:s3:::${var.environment}-states/*"]
     },
     {
        "Effect": "Allow",
        "Action": ["kms:Decrypt"],
        "Resource": ["${var.s3_kms_key_arn}"]
      }
    ]
}
EOA
}
