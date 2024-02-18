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

variable "client_name" {
  description = "Client name for tags generation"
  type        = string
  default     = "client"
}

variable "env_type" {
  description = "Environment type for tags generation"
  type        = string
  default     = "env"
}

variable "number_of_eips" {
  default = 0
}
