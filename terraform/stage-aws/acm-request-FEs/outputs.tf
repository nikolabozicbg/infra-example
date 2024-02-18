output "cert_arn" {
  description = "Certificate ARN value"
  value       = aws_acm_certificate.cert.arn
}

output "cert_validation_params" {
  value = <<EOF
  The domain to be validated: ${aws_acm_certificate.cert.domain_name}
  The region for the domain to be validated: ${var.aws_region == "us-east-1" ? join("", [var.aws_region, " - Global"]) : var.aws_region}
  The method for the validation: ${aws_acm_certificate.cert.validation_method}
EOF
}

output "cert_validation_params_vals" {
  value = aws_acm_certificate.cert.validation_method == "DNS" ? aws_acm_certificate.cert.domain_validation_options : length(aws_acm_certificate.cert.validation_emails) > 0 ? toset(aws_acm_certificate.cert.validation_emails) : { list = "empty" }
}

output "cert_validation_status" {
  description = "Current cert validation status"
  value       = aws_acm_certificate.cert.status
}

output "cert_validity_period_END" {
  value = aws_acm_certificate.cert.not_after
}

output "cert_validity_period_START" {
  value = aws_acm_certificate.cert.not_before
}
