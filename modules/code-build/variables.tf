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