output "bucket_arn" {
  description = "The arn for the website bucket"
  value       = aws_s3_bucket.general_bucket.arn
}

output "bucket" {
  description = "The bucket"
  value       = aws_s3_bucket.general_bucket.bucket
}

output "website_url"{
  description = "The URL for the static website bucket"
  value = try(aws_s3_bucket_website_configuration.website_bucket_configuration[0].website_endpoint, "")
}