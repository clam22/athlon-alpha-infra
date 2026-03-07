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
  api_url = "http://${module.network.lb_dns_name}"
  depends_on = [ module.network ]
}

#Backend
#Network 
module "network" {
  source               = "../../modules/network"
  vpc_instance_tenancy = "default"
}


#Cognito User Pool
module "cognito" {
  source = "../../modules/cognito"
  environment = var.environment
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

#CognitoClientSecret Secrets Manager
resource "aws_secretsmanager_secret" "cognito_client_secret" {
  name = "athlon/${var.environment}/cognito/client-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "cognito_client_secret" {
  secret_id = aws_secretsmanager_secret.cognito_client_secret.id
  secret_string = module.cognito.client_secret
}

#ECS Cluster
module "ecs_cluster" {
  source             = "../../modules/ecs"
  environment        = var.environment
  aws_region = var.aws_region
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
  cognito_pool_arn = module.cognito.arn
  cognito_user_pool_id = module.cognito.user_pool_id
  cognito_client_id = module.cognito.client_id
  cognito_client_secret_arn = aws_secretsmanager_secret.cognito_client_secret.arn
  frontend_endpoint = "http://${module.s3.website_url}"
  depends_on         = [module.network, module.rds_postgresql, module.redis_cache]
}









