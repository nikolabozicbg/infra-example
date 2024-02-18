variable "assume_role_arn" {
  description = "ARN from AWS for the role to assume"
  type        = string
}

variable "aws_region" {
  description = "Specify AWS Region"
  type        = string
}

variable "aws_profile" {
  description = "Specify AWS profile with propper credentials"
  type        = string
}

variable "client" {
  type        = string
  description = "Client name for tagging"
  default     = "syllo"
}

variable "env" {
  type        = string
  description = "Environment tag for tagging"
  default     = "dev"
}

variable "domain_name" {
  type        = string
  description = "Desired domain name"
}

variable "validation_method" {
  type        = string
  description = "Certificate validation method"
  default     = "DNS"
}

variable "certificate_transparency_logging_preference" {
  type        = bool
  description = "Enable transparency logging for cert"
  default     = true
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "List of desired alternative sub-domain names"
  default     = []
}
