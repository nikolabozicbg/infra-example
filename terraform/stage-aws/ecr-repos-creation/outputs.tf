output "Repo_URL" {
  value       = [for r in aws_ecr_repository.this : r.repository_url]
  description = "ECR repo URL value"
}
