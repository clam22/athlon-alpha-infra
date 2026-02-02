output "code_build_project_arn" {
  description = "The ARN value of the Code Build Project"
  value       = aws_codebuild_project.codebuild_project.arn
}

output "code_build_project_name" {
  description = "The name of the Code Build Project"
  value       = aws_codebuild_project.codebuild_project.name

}