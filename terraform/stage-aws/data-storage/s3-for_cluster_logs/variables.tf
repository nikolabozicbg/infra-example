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

variable "bucket_name_id" {
  description = "Specify bucket name"
  type        = string
  default     = "syllo"
}

variable "nodeinstance_role_arn" {
  description = "ARN of the k8s NodeGroup managed nodes instance IAM role"
  type        = string
}

variable "clster_role_arn" {
  description = "ARN of the k8s nodes IAM role"
  type        = string
}

variable "data_retention_days" {
  description = "Specify the number of days to retain data in the bucket"
  type        = number
  default     = 90
}

variable "move_to_glacier" {
  description = "Specify the number of days to move data to Glacier"
  type        = number
  default     = 15
}

variable "client" {
  type        = string
  description = "Client name for tagging"
  default     = "syllo"
}

variable "client_blob" {
  type        = string
  description = "Shorthand Client name without spaces or special characters for resource naming and/or tagging"
  default     = "syllo"
}

variable "env" {
  type        = string
  description = "Environment tag for tagging"
  default     = "prod"
}
