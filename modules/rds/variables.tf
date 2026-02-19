variable "environment" {
  description = "The environment name for deployment"
  type        = string
}

variable "db_username" {
  description = "The username for the rds database"
  type        = string
}

variable "db_password" {
  description = "The password for the rds database"
  type        = string
}

variable "security_group_ids" {
  description = "A list of security group ids"
  type        = list(string)
}

variable "subnet_group_name" {
  description = "The name of the DB subnet group"
  type        = string
}

