output "iam_role_arn" {
  description = "The ARN value for the IAM Role"
  value       = aws_iam_role.iam_role.arn
}

output "iam_role_name" {
  description = "The name of the of the IAM Role"
  value       = aws_iam_role.iam_role.name
}