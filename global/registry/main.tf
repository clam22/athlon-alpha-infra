module "ecr_repository" {
  source               = "../../modules/ecr"
  repository_name      = "athlon-alpha/althlon-alpha-api"
  image_tag_mutability = "MUTABLE"
  allow_scan_on_push   = true
}