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

variable "vpc_id" {
  description = "Targeted VPC ID"
  type        = string
}

variable "allow_ingress_cidr_blocks" {
  description = "List of CIDR blocks to allow asses from"
  type        = list(string)
  default     = []
}

variable "replication_group_id" {
  description = "Replication group ID"
  type        = string
}

variable "node_type" {
  description = "Node size"
  type        = string
  default     = "cache.t3.micro"
}

variable "number_of_clusters" {
  description = "Desired number of clusters"
  type        = number
  default     = 2
}

variable "auto_failover" {
  description = "Enable auto failover feature"
  type        = bool
  default     = true
}

variable "replication_group_desc" {
  description = "Replication group description"
  type        = string
  default     = "Syllo redis cluster"
}

variable "redis_version" {
  description = "Redis version"
  type        = string
  default     = ""
}

variable "redis_port" {
  description = "Redis port"
  type        = number
  default     = 6379
}

variable "notifications" {
  description = "Topic arn to be used for notifications"
  type        = string
  default     = ""
}

variable "retention_period" {
  description = "Retention period for backups"
  type        = number
  default     = 7
}

variable "apply_now" {
  description = "Apply changes immediately"
  type        = bool
  default     = false
}

variable "use_existing_security_groups" {
  description = "Set to true if you have SG predefined"
  type        = bool
  default     = false
}
