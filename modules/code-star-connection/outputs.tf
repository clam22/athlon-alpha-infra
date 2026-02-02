output "codestar_connection_arn" {
  description = "The ARN value of the CodeStar connection"
  value       = aws_codestarconnections_connection.repository_connection.arn
}