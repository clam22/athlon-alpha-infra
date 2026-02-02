variable "aws_region" {
  description = "The region for AWS deployment"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "The deployment environment"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Invalid environement specified. The only valid values are: dev, staging or prod"
  }
}

variable "website_index_document_suffix" {
  description = "The index document suffix for the S3 static website"
  type        = string
  default     = "index.html"
}

variable "website_error_document_key" {
  description = "The key for the error document for the S3 static website"
  type        = string
  default     = "error.html"

}

variable "allow_public_bucket_access" {
  description = "Allow public access to the bucket"
  type        = bool
  default     = true
}

variable "enable_static_website_hosting" {
  description = "Enable static website hosting feature of the S3 bucket"
  type        = bool
  default     = true
}