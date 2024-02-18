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

variable "group_name" {
  description = "The group's name. The name must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: =,.@-_.. Group names are not distinguished by case. For example, you cannot create groups named both 'ADMINS' and 'admins'."
  type        = string
}

variable "user_name" {
  description = "Name the user to be crated"
  type        = string
}

variable "web_site_bucket_name" {
  type = string
}

variable "admin_site_bucket_name" {
  type = string
}

variable "account_id" {
  description = "The 12-digit Account number"
  type        = string
}
