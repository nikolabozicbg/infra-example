output "Subnet-IDs" {
  value       = data.aws_subnets.private.ids
  description = "Private subnets ID"
}

output "redis_endpoint" {
  value = aws_elasticache_replication_group.syllo_redis_cluster.primary_endpoint_address
}
