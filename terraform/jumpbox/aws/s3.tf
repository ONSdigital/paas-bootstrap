resource "aws_s3_bucket_object" "jumpbox-var-store" {
  bucket = "${var.state_bucket_id}"
  acl    = "private"
  key    = "jumpbox/jumpbox-variables.yml"
  source = "/dev/null"
}
