variable "artifact_bucket_name" {
  description = "The name of the artifact bucket"
  type        = string
}

variable "codeconnection_name" {
  description = "The name for CodeStar connection"
  type        = string
}

variable "codeconnection_provider_type" {
  description = "The provider type for the CodeStar connection"
  type        = string
}

variable "website_bucket_name" {
  description = "The bucket name of the static website"
  type        = string
}

variable "full_repository_id" {
  description = "The ID of the respository"
  type        = string
}

