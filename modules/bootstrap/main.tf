resource "aws_kms_key" "state_key" {
  description             = "${var.name}"
  deletion_window_in_days = "${var.deletion_window_in_days}"
}

resource "aws_s3_bucket" "state_bucket" {
  bucket_prefix = "${var.name}"
  acl           = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.state_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
