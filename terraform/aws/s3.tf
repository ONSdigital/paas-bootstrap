resource "aws_kms_key" "paas_state_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}

resource "aws_s3_bucket" "paas_states" {
  bucket = "${var.environment}-states"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.paas_state_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PrivateAclPolicy",  "Effect": "Deny",
      "Principal": { "AWS": "*"},
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${var.environment}-states/*"
      ],
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-acl": [
            "private"
          ]
        }
      }
    }
  ]
}
EOF
}
