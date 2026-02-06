module "ecr_repository" {
  source = "../../../modules/ecr"
  repository_name = var.repository_name
  image_tag_mutability = var.image_tag_mutability
  allow_scan_on_push = var.allow_scan_on_push
}

