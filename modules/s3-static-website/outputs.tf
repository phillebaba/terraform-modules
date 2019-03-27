output "s3_website_endpoint" {
  value = "${aws_s3_bucket.default.website_endpoint}"
}
