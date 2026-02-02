

resource "aws_codestarconnections_connection" "repository_connection" {
  name          = var.name
  provider_type = var.provider_type
}