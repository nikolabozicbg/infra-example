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

variable "clster_role_arn" {
  description = "ARN of the k8s nodes IAM role"
  type        = string
}

variable "allow_user_arn" {
  description = "ARN of the user that will be configured in FS service and that has polica attached to allow acces to the bucket"
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
