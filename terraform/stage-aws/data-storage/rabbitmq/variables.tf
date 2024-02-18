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

variable "vault_address" {
  default     = "https://vault.pannovate.net"
  description = "URL of the Vault server."
  type        = string
}

variable "vault_secrets_key" {
  description = "The path in Vault to the secret that holds values for this resource."
  type        = string
}

variable "broker_name" {
  description = "(Required) Valid name of the broker."
  type        = string
}

variable "engine_type" {
  default     = "RabbitMQ"
  description = "(Required) Type of broker engine. Valid values are ActiveMQ and RabbitMQ."
  type        = string
}

variable "engine_version" {
  description = "(Required) Version of the broker engine. See: https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/broker-engine.html"
  type        = string
}

variable "instance_type" {
  description = "(Required) Broker's instance type. For example, mq.t3.micro, mq.m5.large."
  type        = string
  default     = "mq.t3.micro"
}

variable "username" {
  description = "(Required) Username of the user."
  sensitive   = true
  type        = string
}

variable "password" {
  description = "(Required) Password of the user. It must be 12 to 250 characters long, at least 4 unique characters, and must not contain commas."
  sensitive   = true
  type        = string
}

variable "apply_now" {
  description = "(Optional) Apply changes immediately."
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  default     = true
  description = "(Optional) Whether to automatically upgrade to new minor versions of brokers as Amazon MQ makes releases available."
  type        = bool
}

variable "deployment_mode" {
  default     = "SINGLE_INSTANCE"
  description = "(Optional) Deployment mode of the broker. Valid values are SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ, and CLUSTER_MULTI_AZ."
  type        = string
}

variable "publicly_accessible" {
  description = "(Optional) Whether to enable connections from applications outside of the VPC that hosts the broker's subnets."
  type        = bool
}

variable "vpc_id" {
  description = "Targeted VPC ID"
  type        = string
}

variable "allow_ingress_cidr_blocks" {
  description = "List of CIDR blocks to allow access from"
  type        = list(string)
  default     = []
}

variable "use_custom_port" {
  description = "(Optional) Custom port for ingress rules."
  type        = number
}

variable "use_existing_security_groups" {
  description = "Set to true if you have SG predefined"
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "(Optional) List of security group IDs assigned to the broker."
  type        = list(string)
}

variable "subnet_ids" {
  description = "(Optional) List of subnet IDs in which to launch the broker. A SINGLE_INSTANCE deployment requires one subnet. An ACTIVE_STANDBY_MULTI_AZ deployment requires multiple subnets."
  type        = list(string)
}

variable "maintenance_window_start" {
  description = "(Optional) Configuration block for the maintenance window start time."
  type        = map(string)
}

variable "additional_tags" {
  default     = {}
  description = "(Optional) A map of tags to additionaly assingn to the auto-generated ones."
  type        = map(string)
}


variable "custom_kms_arn" {
  default     = ""
  description = "(Optional) Amazon Resource Name (ARN) of Key Management Service (KMS) Customer Master Key (CMK) to use for encryption at rest. Requires setting use_aws_owned_key to false. To perform drift detection when AWS-managed CMKs or customer-managed CMKs are in use, this value must be configured."
  type        = string
}
