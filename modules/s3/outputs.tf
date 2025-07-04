output "bucket_name" {
  value = aws_s3_bucket.bucket.id
}
 output "artifact_bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}
