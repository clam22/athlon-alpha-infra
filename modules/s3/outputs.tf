output "bucket_arn" {
  description = "The arn for the website bucket"
  value       = aws_s3_bucket.general_bucket.arn
}

output "bucket" {
  description = "The bucket"
  value       = aws_s3_bucket.general_bucket.bucket
}