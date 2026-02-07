resource "aws_codeconnections_connection" "repository_connection" {
  name          = var.name
  provider_type = var.provider_type
}