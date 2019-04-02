# S3
resource "aws_s3_bucket" "default" {
  bucket = "${var.domain_name}"
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["${var.domain_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  website {
    index_document = "${var.index_document}"
    error_document = "${var.error_document}"

    routing_rules = <<EOF
    [{
      "Redirect": {
        "ReplaceKeyPrefixWith": "index.html"
      },
      "Condition": {
        "KeyPrefixEquals": "/"
      }
    }]
    EOF
  }
  tags = "${var.tags}"
}

data "aws_iam_policy_document" "s3_public_policy" {
  statement {
    sid       = "AllowPublicRead"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.default.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = "${aws_s3_bucket.default.id}"
  policy = "${data.aws_iam_policy_document.s3_public_policy.json}"
}

