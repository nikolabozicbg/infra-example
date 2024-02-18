output "Subnet-IDs" {
  value       = length(var.private_subnet_ids) > 0 ? var.private_subnet_ids : data.aws_subnets.private.ids
  description = "Private subnets ID"
}

output "Access_allowed_from-to_CIDRs" {
  value       = length(var.allow_ingress_cidr_blocks) > 0 ? var.allow_ingress_cidr_blocks : [data.aws_vpc.selected.cidr_block]
  description = "Security rules access from/to CIDR blocks"
}

output "RDS_endpoint" {
  value = module.rds-aurora.rds_cluster_endpoint
}
output "DB_name" {
  value     = module.rds-aurora.rds_cluster_database_name
  sensitive = true
}

output "DB_port" {
  value = module.rds-aurora.rds_cluster_port
}

output "DB_master_username" {
  value     = module.rds-aurora.rds_cluster_master_username
  sensitive = true
}
