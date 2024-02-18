locals {
  domain = var.domain_name

  domain_name = trimsuffix(local.domain, ".")
}

resource "aws_acm_certificate" "cert" {
  domain_name               = local.domain_name
  validation_method         = var.validation_method # DNS by default
  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }

  options {
    certificate_transparency_logging_preference = var.certificate_transparency_logging_preference ? "ENABLED" : "DISABLED"
  }
}
