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

variable "client_tag" {
  description = "Client name for tags creation"
  type        = string
}

variable "client_blob" {
  description = "Short client name without spaces or special characters for programatic naming of resources"
  type        = string
}

variable "environment_tag" {
  description = "Some desired name for environment tag"
  type        = string
}

variable "user_name" {
  description = "Name the user to be crated"
  type        = string
}

variable "uploads_bucket_name" {
  type = string
}
