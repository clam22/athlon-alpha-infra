data "terraform_remote_state" "dev_env_state_file" {
  backend = "s3"
  config = {
    bucket = "athlon-alpha-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "eu-north-1"
  }
}

data "terraform_remote_state" "registry_state_file" {
  backend = "s3"
  config = {
    bucket = "athlon-alpha-terraform-state"
    key    = "registry/terraform.tfstate"
    region = "eu-north-1"
  }
}