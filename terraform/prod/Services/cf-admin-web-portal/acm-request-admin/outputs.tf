output "cert_arn" {
  description = "Certificate ARN value"
  value       = aws_acm_certificate.admin_cert.arn
}

output "cert_validation_status" {
  description = "Current cert validation status"
  value       = aws_acm_certificate.admin_cert.status
}

output "cert_validation_params" {
  value = <<EOF
  The domain to be validated: ${aws_acm_certificate.admin_cert.domain_name}
  The region for the domain to be validated: ${var.aws_region == "us-east-1" ? join("", [var.aws_region, " - Global"]) : var.aws_region}
  The method for the validation: ${aws_acm_certificate.admin_cert.validation_method}
EOF
}

output "cert_validation_params_vals" {
  value = aws_acm_certificate.admin_cert.validation_method == "DNS" ? aws_acm_certificate.admin_cert.domain_validation_options : length(aws_acm_certificate.admin_cert.validation_emails) > 0 ? toset(aws_acm_certificate.admin_cert.validation_emails) : { list = "empty" }
}
