variable "environment" {
  description = "The staging envionment name"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to launch ec2 instances in"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of Security group IDs"
  type        = list(string)
}

variable "ecr_repository_url" {
  description = "The name of the ECR Repository"
  type        = string
}

variable "rds_hostname" {
  description = "The URL for the RDS Database"
  type        = string
  sensitive   = true
}


variable "db_port" {
  description = "The port of the RDS Database"
  type        = string
}

variable "db_name" {
  description = "The name of the RDS Database"
  type        = string
}

variable "db_user" {
  description = "The username of the RDS Database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password of the RDS Database"
  type        = string
  sensitive   = true
}

variable "redis_endpoint" {
  description = "The URL of the ElastiCache Redis Cluster"
  type        = string
  sensitive   = true
}

variable "redis_port" {
  description = "The port of the ElastiCache Redis Cluster"
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the Load Balancer"
  type        = string
}
