output "connection_arn" {
  description = "The ARN value of the CodeStar connection"
  value       = aws_codeconnections_connection.repository_connection.arn
}