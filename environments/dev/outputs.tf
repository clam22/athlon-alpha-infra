output "bucket_website_arn" {
  description = "The ARN of the S3 Static website bucket"
  value       = module.s3.bucket_arn
}

output "ecs_cluster_name" {
  description = "The name of the ECS Cluster"
  value       = module.ecs_cluster.cluster_name
}

output "ecs_service_name" {
  description = "The name of the ECS Service"
  value       = module.ecs_cluster.service_name
}

output "redis_endpoint" {
  value = module.redis_cache.redis_endpoint
}

output "rds_endpoint" {
  value = module.rds_postgresql.rds_address
}