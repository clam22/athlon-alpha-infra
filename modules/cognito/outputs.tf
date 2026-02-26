output "user_pool_id" {
  value = aws_cognito_user_pool.pool.id
  sensitive = true
}

output "client_id" {
  value = aws_cognito_user_pool_client.api_client.id
  sensitive = true
}

output "client_secret" {
  value = aws_cognito_user_pool_client.api_client.client_secret
  sensitive = true
}

output "arn" {
  value = aws_cognito_user_pool.pool.arn
}