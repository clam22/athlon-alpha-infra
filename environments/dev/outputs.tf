output "bucket_website_arn" {
  description = "The ARN of the S3 Static website bucket"
  value       = module.s3.bucket_arn
}
