resource "aws_kms_key" "cf_blobstore_key" {
  description             = "This key is used to encrypt CF objects in blobstore"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags {
    Name        = "${var.environment}-cf-blobstore-key"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket" "cf_buildpacks" {
  bucket = "${var.s3_prefix}-${var.environment}-cf-buildpacks"
  acl    = "private"

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.cf_blobstore_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags {
    Name        = "${var.s3_prefix}-${var.environment}-cf-buildpacks"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket" "cf_droplets" {
  bucket = "${var.s3_prefix}-${var.environment}-cf-droplets"
  acl    = "private"

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.cf_blobstore_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags {
    Name        = "${var.s3_prefix}-${var.environment}-cf-droplets"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket" "cf_packages" {
  bucket = "${var.s3_prefix}-${var.environment}-cf-packages"
  acl    = "private"

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.cf_blobstore_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags {
    Name        = "${var.s3_prefix}-${var.environment}-cf-packages"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket" "cf_resource_pool" {
  bucket = "${var.s3_prefix}-${var.environment}-cf-resource-pool"
  acl    = "private"

  versioning {
    enabled = false
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.cf_blobstore_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags {
    Name        = "${var.s3_prefix}-${var.environment}-cf-resource-pool"
    Environment = "${var.environment}"
  }
}
