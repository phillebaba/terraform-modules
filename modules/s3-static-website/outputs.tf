output "website_endpoint" {
  value = "${aws_s3_bucket.default.website_endpoint}"
}

output "bucket_name" {
  value = "${aws_s3_bucket.default.id}"
}
