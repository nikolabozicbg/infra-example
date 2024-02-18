locals {
  domain = var.domain_name

  domain_name = trimsuffix(local.domain, ".")
}

resource "aws_acm_certificate" "admin_cert" {
  domain_name               = local.domain_name
  validation_method         = var.validation_method
  subject_alternative_names = var.subject_alternative_names

  options {
    certificate_transparency_logging_preference = var.certificate_transparency_logging_preference ? "ENABLED" : "DISABLED"
  }

  tags = {
    Client = var.client
    Env    = var.env
  }
}
