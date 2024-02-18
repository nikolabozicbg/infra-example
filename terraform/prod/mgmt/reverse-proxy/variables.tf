variable "assume_role_arn" {
  description = "Role to assume for AWS API calls"
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

variable "ami" {
  description = "AMI to use for the instance."
  type        = string
}

variable "instance_name" {
  type = string
  description = "A short name that will be visible in AWS EC2 console"
}

variable "vpc_id" {
  description = ""
  type        = string
}

variable "availability_zone" {
  description = "AZ to start the instance in."
  type        = string
}

variable "subnet_id" {
  description = "VPC Subnet ID to launch in."
  type        = string
}

variable "security_group_ids" {
  description = " A list of security group IDs to associate with"
  type        = list(string)
}

variable "instance_type" {
  description = "The instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance."
  type        = string
}

variable "key_pair_name" {
  description = "Key name of the Key Pair to use for the instance; which can be managed using the aws_key_pair resource."
  type        = string
}

variable "automatic_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC."
  type        = bool
}

variable "reserve_public_eip_address" {
  description = "Whether to create a public IP address to associate with an instance in a VPC."
  type        = bool
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC."
  type        = string
}

variable "secondary_private_ips" {
  description = "A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. Can only be assigned to the primary network interface (eth0) attached at instance creation, not a pre-existing network interface i.e. referenced in a network_interface block"
  type        = list(string)
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. Defaults true."
  type        = bool
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  type        = string
}

variable "cpu_credits" {
  description = "Credit option for CPU usage. Valid values include standard or unlimited. T3 instances are launched as unlimited by default. T2 instances are launched as standard by default."
  type        = string
}

variable "volume_size_gb" {
  type = number
}
