output "ecs_instance_security_group_ids" {
  description = "A list of security group IDs for ECS Instances"
  value       = [aws_security_group.ecs_instances_sg.id]
}

output "rds_security_group_ids" {
  description = "A list of security group IDs for RDS Database"
  value       = [aws_security_group.rds_sg.id]
}

output "redis_security_group_ids" {
  description = "A list of security group IDs for Redis Cache Cluster"
  value       = [aws_security_group.redis_sg.id]
}

output "private_app_subnet_ids" {
  description = "A list of private app subnet IDs"
  value       = [for subnet in aws_subnet.private_app_subnet : subnet.id]
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.rds_subnet_group.name
}

output "elasticache_subnet_group_name" {
  description = "The name of the ElastiCache subnet group"
  value       = aws_elasticache_subnet_group.cache_subnet_group.name
}

output "lb_target_group_arn" {
  description = "The Load Balancer Target group"
  value       = aws_lb_target_group.api.arn
}