output "repository_url" {
  description = "The value of the repository URL"
  value       = module.ecr_repository.repository_url
}

output "repository_name" {
  description = "The value of the repository Name"
  value       = module.ecr_repository.respository_name
}