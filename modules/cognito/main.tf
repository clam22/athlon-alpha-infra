resource "aws_cognito_user_pool" "pool" {
  name = "athlon-user-pool-${var.environment}"

  password_policy {
    minimum_length = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers = true
    require_symbols = true
  }

  auto_verified_attributes = ["email"]

  username_attributes = ["email"]

  schema {
    attribute_data_type = "String"
    name = "email"
    required = true
    mutable = false
  }

  schema {
    attribute_data_type = "String"
    name = "family_name"
    required = true
    mutable = true
  }

  schema {
    attribute_data_type = "String"
    name = "given_name"
    required = true
    mutable = true
  }
}

resource "aws_cognito_user_pool_client" "api_client" {
  name = "athlon-api-client-${var.environment}"
  user_pool_id = aws_cognito_user_pool.pool.id

  generate_secret = true

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

resource "aws_cognito_user_group" "user" {
  name = "User"
  user_pool_id = aws_cognito_user_pool.pool.id
  description = "Default Application User"
  precedence = 10
}

resource "aws_cognito_user_group" "player" {
  name = "Player"
  user_pool_id = aws_cognito_user_pool.pool.id
  description = "Default Application User"
  precedence = 2
}

resource "aws_cognito_user_group" "admin" {
  name = "Admin"
  user_pool_id = aws_cognito_user_pool.pool.id
  description = "Application Adminstrator"
  precedence = 1
}

resource "aws_cognito_user" "superuser" {
  user_pool_id = aws_cognito_user_pool.pool.id
  username = "superuser@email.com"

  attributes = {
    email = "superuser@email.com"
    given_name = "Super"
    family_name = "User"
  }
}

resource "aws_cognito_user_in_group" "add_admin_to_admin_group" {
  user_pool_id = aws_cognito_user_pool.pool.id
  group_name = aws_cognito_user_group.admin.name
  username = aws_cognito_user.superuser.username
}