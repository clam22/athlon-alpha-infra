resource "aws_s3_bucket" "general_bucket" {
  bucket        = var.bucket_name
  tags          = var.tags
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "general_bucket_access_block" {
  bucket                  = aws_s3_bucket.general_bucket.id
  block_public_acls       = var.allow_public_bucket_access ? false : true
  block_public_policy     = var.allow_public_bucket_access ? false : true
  ignore_public_acls      = var.allow_public_bucket_access ? false : true
  restrict_public_buckets = var.allow_public_bucket_access ? false : true
}

resource "aws_s3_bucket_website_configuration" "website_bucket_configuration" {
  count  = var.enable_static_website_hosting ? 1 : 0
  bucket = aws_s3_bucket.general_bucket.id

  index_document {
    suffix = var.index_document_suffix
  }

  error_document {
    key = var.error_document_key
  }
}



data "aws_iam_policy_document" "bucket_resource_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.general_bucket.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "general_bucket_policy" {
  bucket = aws_s3_bucket.general_bucket.id
  policy = data.aws_iam_policy_document.bucket_resource_policy.json
}
