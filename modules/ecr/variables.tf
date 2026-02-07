variable "repository_name" {
  description = "The name of the repository"
  type        = string
  nullable    = false
}

variable "image_tag_mutability" {
  description = "Type of Mutability for the image tag"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE", "MUTABLE_WITH_EXCLUSION", "IMMUTABLE_WITH_EXCLUSION"], var.image_tag_mutability)
    error_message = "The image tag mutability can only be 'MUTABLE' or 'IMMUTABLE'"
  }
}

variable "allow_scan_on_push" {
  description = "Allow images to be scanned when pushed to ECR"
  type        = bool
  default     = true
}