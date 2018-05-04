resource "aws_s3_bucket_object" "jumpbox-var-store" {
  bucket                 = "${var.state_bucket_id}"
  acl                    = "private"
  key                    = "jumpbox/jumpbox-variables.yml"
  source                 = "/dev/null"
  server_side_encryption = "aws:kms"
  kms_key_id             = "${var.s3_kms_key_arn}"
}

resource "aws_s3_bucket_object" "jumpbox-state" {
  bucket                 = "${var.state_bucket_id}"
  acl                    = "private"
  key                    = "jumpbox/jumpbox-state.json"
  content                = "{}"
  server_side_encryption = "aws:kms"
  kms_key_id             = "${var.s3_kms_key_arn}"
}
