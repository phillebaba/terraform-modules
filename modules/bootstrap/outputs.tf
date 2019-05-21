output "state_bucket_name" {
  value = "${aws_s3_bucket.state_bucket.name}"
}

output "state_kms_key_id" {
  value = "${aws_kms_key.state_key.id}"
}
