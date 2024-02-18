output "doc_db_cluster_members" {
  value       = aws_docdb_cluster.syllo.cluster_members
  description = "List of DocDB cluster members/instances"
}

output "doc_db_cluster_resource_id" {
  value       = aws_docdb_cluster.syllo.cluster_resource_id
  description = "DocDB cluster resource ID"
}

output "doc_db_cluster_endpoint" {
  value       = aws_docdb_cluster.syllo.endpoint
  description = "DocDB cluster endpoint DNS address"
}

output "doc_db_cluster_readonly_endpoint" {
  value       = aws_docdb_cluster.syllo.reader_endpoint
  description = "DocDB cluster read-only endpoint"
}

output "doc_db_cluster_connection_string" {
  value = "mongodb://<username>:<password>@${aws_docdb_cluster.syllo.endpoint}:${var.mongo_port}/<dbname>?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}

