locals {
  db_hostname = data.terraform_remote_state.dev_env_state_file.outputs.db_hostname
  db_port = data.terraform_remote_state.dev_env_state_file.outputs.db_port
  db_name = data.terraform_remote_state.dev_env_state_file.outputs.db_name
  db_user = data.terraform_remote_state.dev_env_state_file.outputs.db_user
  db_password = data.terraform_remote_state.dev_env_state_file.outputs.db_password
}