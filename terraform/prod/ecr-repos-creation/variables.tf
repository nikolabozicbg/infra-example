variable "assume_role_arn" {
  type        = string
  description = "ARN from AWS for the role to assume"
}

variable "aws_region" {
  description = "Specify AWS Region"
  type        = string
}

variable "aws_profile" {
  description = "Specify AWS profile with propper credentials"
  type        = string
}

variable "billing_code_tag" {
  description = "Some desired name for billing tag"
  type        = string
}

variable "client" {
  description = "Client name for tags creation"
  type        = string
}

variable "client_blob" {
  description = "Short client name for programatic namong of resources"
  type        = string
}

variable "environment_tag" {
  description = "Some desired name for environment tag"
  type        = string
}

variable "repos_list" {
  type        = list(string)
  description = "List of repos to be created"
  default     = ["Syllo"]
}

variable "scan_on_push" {
  type        = bool
  description = "Enable scan on push feature"
  default     = true
}

variable "tag_mutability" {
  type        = string
  description = "Enable image tag mutability"
  default     = "MUTABLE"
}

variable "enc_type" {
  type        = string
  description = "(optional) describe your variable"
  default     = "AES256"
}

variable "enc_key" {
  type        = string
  description = "Custom kms key arn, if left empty, AWS default to be used"
  default     = ""
}
