locals {
  environment_mapping = {
    dev     = "Development"
    staging = "Staging"
    prod    = "Production"
  }

  deployment_environment = lookup(local.environment_mapping, var.environment, local.environment_mapping.dev)
}