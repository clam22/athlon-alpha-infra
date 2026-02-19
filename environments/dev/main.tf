#FrontEnd
#S3 Static Website Bucket
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

#Backend
#Network 
module "network" {
  source               = "../../modules/network"
  vpc_instance_tenancy = "default"
}

#RDS Database
module "rds_postgresql" {
  source             = "../../modules/rds"
  environment        = var.environment
  db_username        = var.db_username
  db_password        = var.db_password
  security_group_ids = module.network.rds_security_group_ids
  subnet_group_name  = module.network.db_subnet_group_name
  depends_on         = [module.network]
}

#ElastiCache Redis
module "redis_cache" {
  source             = "../../modules/elasticache"
  environment        = var.environment
  subnet_group_name  = module.network.elasticache_subnet_group_name
  security_group_ids = module.network.redis_security_group_ids
  depends_on         = [module.network]
}

#ECS Cluster
module "ecs_cluster" {
  source             = "../../modules/ecs"
  environment        = var.environment
  ecr_repository_url = data.terraform_remote_state.registry_state_file.outputs.repository_url
  subnet_ids         = module.network.private_app_subnet_ids
  security_group_ids = module.network.ecs_instance_security_group_ids
  rds_hostname       = module.rds_postgresql.rds_address
  db_port            = module.rds_postgresql.db_port
  db_name            = module.rds_postgresql.db_name
  db_user            = module.rds_postgresql.db_username
  db_password        = module.rds_postgresql.db_password
  redis_endpoint     = module.redis_cache.redis_endpoint
  redis_port         = module.redis_cache.redis_port
  target_group_arn   = module.network.lb_target_group_arn
  depends_on         = [module.network, module.rds_postgresql, module.redis_cache]

}









