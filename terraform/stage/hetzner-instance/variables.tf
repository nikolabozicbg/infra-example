variable "client" {
  type    = string
  default = "test"
}

variable "env" {
  type    = string
  default = "test"
}

variable "project" {
  type    = string
  default = "syllo"
}

variable "vault_address" {
  type    = string
  default = "https://vault.pannovate.net"
}

variable "hcloud_token_name" {
  type    = string
  default = "syllo-project-token"
}
variable "hcloud_token_path" {
  type        = string
  sensitive   = true
  description = "Generate a token on Hetzner cloud for this project an store it in vault. Define here the path to that token in vault."
}

variable "os_image" {
  type        = string
  default     = "debian-10"
  description = "Defining a variable source OS image for an instance."
}

variable "server_type" {
  type        = string
  default     = "cx21"
  description = "Definition of an instance type variable depending on the choice of tariff."
}

variable "location" {
  type        = string
  default     = "nbg1"
  description = "Definition of the region in which the instance will be created."
}

variable "public_ssh_key_name" {
  type        = string
  description = "Descriptive name for the new SSH key to add."
  default     = ""
}
variable "public_ssh_key" {
  type        = string
  sensitive   = true
  description = "Determining the ssh key that will be added to the instance when creating."
  default     = ""
}

variable "use_existing_ssh_keys" {
  type        = bool
  default     = true
  description = "Weather to asign all available keys to this instance."
}

variable "git_branch" {
  description = "The name of the branch to pull the code from during initialization."
  type        = string
}

variable "syllo_user_pass_name" {
  type        = string
  description = "Secrets name in the Vault."
}
variable "syllo_user_pass_path" {
  type        = string
  description = "Secrets path in the vault."
}
variable "npm_token_name" {
  type        = string
  description = "Secrets name in the Vault."
}
variable "npm_token_path" {
  type        = string
  description = "Secrets path in the vault."
}
variable "gitlab_api_token_name" {
  type        = string
  description = "Secrets name in the Vault."
}
variable "gitlab_api_token_path" {
  type        = string
  description = "Secrets path in the vault."
}
variable "syllo_server_url" {
  type        = string
  description = "Desired final URL for this Syllo Back-End instance.\nExample: client.syllo.dev.pannovate.net\nIf not specified it will be generated from: '{var.client}.{var.project}.{var.env}.pannovate.net'"
}
variable "gitlab_deploy_key_name" {
  type        = string
  description = "The name of this instances SSH to insert into GitLab."
}

variable "existing_firewall_name" {
  type        = string
  description = "The name of the existing firewall rule on Hetzner to apply to this instance."
  default     = "Basic_firewall-1"
}

variable "ansible_groups" {
  type = string
  default = ""
}
