output "redis_endpoint" {
  description = "The URL of the Elastic Redis Cluster"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "The port of the Elastic Redis Cluster"
  value       = aws_elasticache_cluster.redis.port
}