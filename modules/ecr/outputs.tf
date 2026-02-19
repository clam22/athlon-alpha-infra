output "repository_url" {
  description = "The URL of the Private Repository"
  value       = aws_ecr_repository.private_repository.repository_url
}

output "respository_name" {
  description = "The name of the repository"
  value       = aws_ecr_repository.private_repository.name
}