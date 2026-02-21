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
  description = "The hostname of the Redis Cluster"
  value = module.redis_cache.redis_endpoint
}

output "rds_endpoint" {
   description = "The hostname of the RDS Cluster"
  value = module.rds_postgresql.rds_address
}

output "db_hostname" {
  description = "The hostname of the RDS database"
  value = module.rds_postgresql.rds_address
  sensitive = true
}

output "db_port" {
  description = "The port of the RDS database"
  value = module.rds_postgresql.db_port
  sensitive = true
}

output "db_name" {
  description = "The name of the RDS database"
  value = module.rds_postgresql.db_name
  sensitive = true
}

output "db_user" {
  description = "The username of the RDS database"
  value = module.rds_postgresql.db_username
  sensitive = true
}

output "db_password" {
  description = "The password of the RDS database"
  value = module.rds_postgresql.db_password
  sensitive = true
}

output "vpc_id" {
  description = "Value of the VPC ID"
  value = module.network.vpc_id
}

output "private_app_subnet_ids" {
  description = "A list of subnet for IDs of the private_app_subnet"
  value = module.network.private_app_subnet_ids
}

output "codepipeline_security_group_ids" {
  description = "A list of security group ids for the CodeBuild instances"
  value = module.network.codebuild_security_group_ids
}

