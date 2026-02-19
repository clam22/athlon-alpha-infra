output "rds_address" {
  description = "The hostname for the RDS database"
  value       = aws_db_instance.rds_postgresql.address
}

output "db_port" {
  description = "The port of the RDS database"
  value       = aws_db_instance.rds_postgresql.port
}

output "db_name" {
  description = "The name of the RDS database"
  value       = aws_db_instance.rds_postgresql.db_name
}

output "db_username" {
  description = "The user of the RDS database"
  value       = aws_db_instance.rds_postgresql.username
  sensitive   = true
}

output "db_password" {
  description = "The password of the RDS database"
  value       = aws_db_instance.rds_postgresql.password
  sensitive   = true
}