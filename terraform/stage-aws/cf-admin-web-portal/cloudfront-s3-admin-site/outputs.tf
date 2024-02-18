output "admin_app_s3_bucket_id" {
  value = aws_s3_bucket.static_website.id
}

output "admin_app_s3_log_bucket_id" {
  value = length(var.existing_log_bucket_id) > 0 ? var.existing_log_bucket_id : aws_s3_bucket.log_bucket[0].id
}

output "admin_app_s3_bucket_domain_name" {
  value = aws_s3_bucket.static_website.bucket_domain_name
}

output "admin_app_cf_website_endpoint" {
  description = "ID of admin app cloudfront distribution"
  value       = aws_cloudfront_distribution.static_website.id
}

output "admin_app_cf_website_domain_name" {
  description = "Domain name of admin app cloudfront distribution"
  value       = aws_cloudfront_distribution.static_website.domain_name
}

output "admin_app_cf_website_status" {
  description = "Status of admin app cloudfront distribution"
  value       = aws_cloudfront_distribution.static_website.status
}
