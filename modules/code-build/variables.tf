variable "build_name" {
  description = "The name of the build"
  type        = string
}

variable "artifact_bucket_arn" {
  description = "The ARN value of the Artifact Bucket"
  type        = string
}

variable "environment_variables" {
  description = "A list of environment variables needed for codebuild to execute"
  type        = map(string)
  default = {

  }
  nullable  = true
  sensitive = true
}

variable "buildspec_file_name" {
  description = "The name of the buildspec.yml file"
  type = string
  default = "buldspec.yml"
}

variable "vpc_id" {
  description = "The value of the VPC ID"
  type = string
}

variable "subnet_ids" {
  description = "A list VPC IDs for CodeBuild Project to run in"
  type = list(string)
}

variable "security_group_ids" {
  description = "A list of security of Security Groups for CodeBuild Project to run in"
}
