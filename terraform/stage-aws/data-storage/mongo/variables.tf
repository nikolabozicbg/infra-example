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

variable "client_blob" {
  type        = string
  description = "Abreviated client name for tagging"
  default     = "syllo"
}

variable "env" {
  type        = string
  description = "Environment tag for tagging"
  default     = "test"
}

variable "vault_address" {
  default     = "https://vault.pannovate.net"
  description = "URL of the Vault server."
  type        = string
}

variable "vault_secrets_key" {
  description = "The path in Vault to the secret that holds values for this resource."
  type        = string
}

variable "vpc_id" {
  description = "Targeted VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of subnet IDs to use for RDS"
  type        = list(string)
  default     = []
}

variable "allow_ingress_cidr_blocks" {
  description = "List of CIDR blocks to allow asses from"
  type        = list(string)
  default     = []
}

variable "docdb_engine_version" {
  type        = string
  description = "DocDB engine version"
  default     = "4.0.0"
}

variable "docdb_param_group_engine_version" {
  type        = string
  description = "Engine version used for param group setup"
  default     = "docdb4.0"
}

variable "param_group_tls_value" {
  type        = string
  description = "Switch for enable/disable TLS connection"
  default     = "enabled"
}

variable "param_group_value_change_method" {
  type        = string
  description = "Defines if param value change required reboot"
  default     = "pending-reboot"
}

variable "storage_encryption" {
  type        = bool
  description = "Enables or disables encryption at rest"
  default     = false
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN for the KMS encryption key. When specifying kms_key_id, storage_encrypted needs to be set to true"
  default     = ""
}

variable "password" {
  type        = string
  description = "Master password to be used. Refer to docs for specific requirements"
}

variable "username" {
  type        = string
  description = "Master username to be used"
  default     = "syllo"
}

variable "mongo_port" {
  type        = number
  description = "Desired port number"
  default     = 27017
}

variable "retention_period" {
  type        = number
  description = "Backup retention period"
  default     = 7
}

variable "backup_window" {
  type        = string
  description = "Preferred backup window"
  default     = "02:00-07:00"
}

variable "cluster_instance_size" {
  type        = string
  description = "Cluster instance desired size"
  default     = "db.r5.large"
}

variable "instances_count" {
  type        = number
  description = "Number of desired instances"
  default     = 2
}

variable "instance_maintenance_window" {
  type        = string
  description = "Desired instance maintenance window"
  default     = "Sun:02:00-Sun:04:00"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Automatic minor software version upgrades"
  default     = false
}

variable "apply_immediately" {
  type        = bool
  description = "Apply changes immediately or during maitenance window"
  default     = false
}
