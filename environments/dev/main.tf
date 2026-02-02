module "s3" {
  source      = "../../modules/s3"
  bucket_name = "athlon-alpha-website-${var.environment}"
  tags = {
    environment = "${var.environment}"
  }
  index_document_suffix         = var.website_index_document_suffix
  error_document_key            = var.website_error_document_key
  enable_static_website_hosting = var.enable_static_website_hosting
  allow_public_bucket_access    = var.allow_public_bucket_access
}

