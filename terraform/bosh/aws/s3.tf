resource "aws_s3_bucket_object" "bosh-var-store" {
  bucket                 = "${var.state_bucket_id}"
  acl                    = "private"
  key                    = "bosh/bosh-variables.yml"
  source                 = "/dev/null"
  server_side_encryption = "aws:kms"
  kms_key_id             = "${var.s3_kms_key_arn}"
}

resource "aws_s3_bucket_object" "bosh-state" {
  bucket                 = "${var.state_bucket_id}"
  acl                    = "private"
  key                    = "bosh/bosh-state.json"
  content                = "{}"
  server_side_encryption = "aws:kms"
  kms_key_id             = "${var.s3_kms_key_arn}"
}
