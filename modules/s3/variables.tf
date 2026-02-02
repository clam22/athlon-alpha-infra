variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "tags" {
  description = "The tags of the S3 bucket"
  type        = map(string)
  default     = {}
}

variable "index_document_suffix" {
  description = "The index document suffix"
  type        = string
  default     = "index.html"
}

variable "error_document_key" {
  description = "The error document key"
  type        = string
  default     = "index.html"
}

variable "enable_static_website_hosting" {
  description = "Enable the static website hosting feature of the S3 bucket"
  type        = bool
  default     = false
  validation {
    condition     = contains([false, true], var.enable_static_website_hosting)
    error_message = "Invalid value specified. The only valid values are: 'true' or 'false'."
  }
}

variable "allow_public_bucket_access" {
  description = "Allow public access to the bucket"
  type        = bool
  default     = true
  validation {
    condition     = contains([false, true], var.allow_public_bucket_access)
    error_message = "Invalid value specified. The only valid values are: 'true' or 'false'."
  }
}

