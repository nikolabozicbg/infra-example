variable "aws_region" {
  description = "Specify AWS region to deploy to"
  type        = string
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "Specify the AWS profile to use for credentials"
  type        = string
}

variable "assume_role_arn" {
  description = "ARN of the role for terragrunt to assume"
  type        = string
}

variable "client" {
  type        = string
  description = "Client name for tagging"
}

variable "client_blob" {
  type        = string
  description = "Shorthand client name for resource naming anr/or tagging"
}

variable "env" {
  type        = string
  description = "Environment tag for tagging"
}

variable "bucket_name_id" {
  description = "Specify bucket name to be created (bucket name must match domain name exactly)"
  type        = string
}

variable "existing_log_bucket_id" {
  description = "Specify previously created bucket for logs"
  type        = string
  default     = ""
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

variable "s3_origin" {
  description = "Specify new S3 origin identifier for this bucket"
  type        = string
}

variable "s3_acces_role_arn" {
  description = "ARN of the IAM that can upload files to S3 bucket"
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN of the k8s nodes IAM role"
  type        = string
}

variable "cf_enabled" {
  description = "Is this distribution enabled to accept requests"
  type        = bool
  default     = true
}

variable "cf_cert_arn" {
  description = "The ARN of the certificate for CloudFront (has to be in us-east-1 at the moment)."
  type        = string
}

variable "cf_minimum_protocol_version" {
  description = "The minimum allowed SSL/TLS protocol version"
  type        = string
  default     = "TLSv1.2_2019"
}

variable "cf_enable_ipv6" {
  type    = bool
  default = false
}

variable "cf_aliases" {
  description = "The list of aliases to use for the same web site at CloudFront"
  type        = list(string)
}

variable "cf_name" {
  description = "The descriptive name for the CloudFront"
  type        = string
}

variable "cf_comment" {
  description = "Text for comment of a CloudFront"
  type        = string
  default     = ""
}

variable "allow_extra_origins" {
  description = "Additional URLs that will access this S3 bucket"
  type        = list(string)
  default     = []
}

variable "web_acl_id" {
  type        = string
  description = "A unique identifier that specifies the AWS WAF web ACL, if any, to associate with this distribution."
  default     = ""
}

variable "hsts_lambda_arn" {
  default     = ""
  description = "ARN of the Lambda function."
  type        = string
}
