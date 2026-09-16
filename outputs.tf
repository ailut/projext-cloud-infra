output "application_data_bucket_name" {
  value = aws_s3_bucket.application_data.bucket
}
output "application_data_bucket_arn" {
  value = aws_s3_bucket.application_data.arn
}