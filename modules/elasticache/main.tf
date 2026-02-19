resource "aws_elasticache_cluster" "redis" {
  cluster_id      = "redis-cluster-${var.environment}"
  engine          = "redis"
  node_type       = "cache.t3.micro"
  num_cache_nodes = 1
  port            = 6379

  subnet_group_name  = var.subnet_group_name
  security_group_ids = var.security_group_ids
}