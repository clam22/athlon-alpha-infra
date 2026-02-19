variable "environment" {
  description = "The environment name for deployment"
  type        = string
}

variable "subnet_group_name" {
  description = "The name of the ElastiCache subnet group"
  type        = string
}

variable "security_group_ids" {
  description = "A list of security group ids for the Elasticache Cluster"
  type        = list(string)
}

