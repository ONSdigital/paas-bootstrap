resource "aws_s3_bucket" "cf-buildpacks" {
  bucket = "${var.environment}-cf-buildpacks"
  acl    = "private"

  tags {
    Name        = "${var.environment}-cf-buildpacks"
    Environment = "${var.environment}"
  }
}
