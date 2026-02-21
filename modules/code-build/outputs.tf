output "arn" {
  description = "The ARN value of the Code Build Project"
  value       = aws_codebuild_project.codebuild_project.arn
}

output "name" {
  description = "The name of the Code Build Project"
  value       = aws_codebuild_project.codebuild_project.name

}