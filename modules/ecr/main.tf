resource "aws_ecr_repository" "private_repository" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = var.allow_scan_on_push
  }
  force_delete = true

}