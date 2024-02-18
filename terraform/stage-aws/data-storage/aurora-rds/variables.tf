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
  default     = "syllo"
  description = "Client name for tagging"
  type        = string
}

variable "env" {
  default     = "dev"
  description = "Environment tag for tagging"
  type        = string
}

variable "vault_address" {
  default = "https://vault.pannovate.net"
  type    = string
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
  default     = []
  description = "List of subnet IDs to use for RDS"
  type        = list(string)
}

variable "allow_ingress_cidr_blocks" {
  default     = []
  description = "List of CIDR blocks to allow asses from"
  type        = list(string)
}

variable "replica_count" {
  default     = 0
  description = "The number of replicas for the DB Cluester group"
  type        = number
}

variable "replica_scale_min" {
  default = 0
}

variable "replica_scale_max" {
  default = 5
}

variable "rds_cluster_name" {
  description = "Desired cluster name"
  type        = string
}

variable "database_name_val" {
  description = "DB name value from the Vault"
  type        = string
}

variable "master_username_val" {
  description = "Master user name value from the Vault"
  type        = string
}

variable "master_password_val" {
  description = "Master user password value from the Vault"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN for encryption KMS key"
  type        = string
}

variable "apply_immediately" {
  default     = false
  description = "Should the change be applied immediately or in scheduled time"
  type        = bool
}

variable "skip_final_snapshot" {
  default     = false
  description = "Should a final snapshot be made beforfe the destruction"
  type        = bool
}

variable "main_instance_type" {
  default     = "db.t3.large"
  description = "Main RDS instance type"
  type        = string
}

variable "replica_instance_type" {
  default     = "db.t3.medium"
  description = "Replica RDS instance type"
  type        = string
}

variable "aurora_engine" {
  default     = "aurora-postgresq"
  description = "Aurora RDS DB Type Aurora for MySQL or for PostgreSQL"
  type        = string
}

variable "aurora_engine_version" {
  default     = "12.6"
  description = "DB Version number compatibility"
  type        = string
}

variable "rds_sg_name" {
  default     = "rds_sg"
  description = "Name for RDS Security Group"
  type        = string
}
