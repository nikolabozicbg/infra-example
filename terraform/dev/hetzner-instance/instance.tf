resource "hcloud_server" "server" {  # Create a server
  name         = local.instance_name # Name server
  image        = var.os_image        # Basic image
  server_type  = var.server_type     # Instance type
  location     = var.location        # Region
  backups      = "false"             # Enable backups
  ssh_keys     = length(var.public_ssh_key) > 0 ? var.use_existing_ssh_keys ? concat(data.hcloud_ssh_keys.all_keys.ssh_keys.*.name, ["${hcloud_ssh_key.user[0].id}"]) : ["${hcloud_ssh_key.user[0].id}"] : var.use_existing_ssh_keys ? data.hcloud_ssh_keys.all_keys.ssh_keys.*.name : []
  # user_data    = data.template_file.user_data.rendered # The script that works when you start
  firewall_ids = length(var.existing_firewall_name) > 0 ? [data.hcloud_firewall.main_firewall.id] : []

  labels = {}

  # IF SOME FILES NEED TO BE TRANSFERED DO THE HOST DURING INITIALIZATION
  # THIS IS NOT RECOMMENDED METHOD BUT IF NECESSERY SUPPOSINGLY IT CAN BE DONE SOMEHOW !!!
  # provisioner "file" {                                     # Copying files to instances
  #   source      = data.template_file.syllo_config.rendered # Path to file on local machine
  #   destination = "/etc/nginx/conf.d/syllo.conf"           # Path to copyto

  #   connection {
  #     type = "ssh"
  #     user = "syllo"
  #     host = self.ipv4_address
  #   }
  # }
}

data "vault_generic_secret" "syllo_user_pass" {
  path = var.syllo_user_pass_path
}

data "vault_generic_secret" "npm_token" {
  path = var.npm_token_path
}

data "vault_generic_secret" "api_token" {
  path = var.gitlab_api_token_path
}

# File definition user-data
data "template_file" "user_data" {
  template = file("${path.module}/user_files/user-data.sh")
  vars = {
    syllo_password          = data.vault_generic_secret.syllo_user_pass.data[var.syllo_user_pass_name]
    npm_token               = data.vault_generic_secret.npm_token.data[var.npm_token_name]
    syllo_config            = data.template_file.syllo_config.rendered
    gitlab_api_access_token = data.vault_generic_secret.api_token.data[var.gitlab_api_token_name]
    gitlab_deploy_key       = var.gitlab_deploy_key_name
    git-branch              = var.git_branch
  }
}

locals {
  server_url_string = length(var.syllo_server_url) > 0 ? var.syllo_server_url : "${var.client}.${var.project}.${var.env}.pannovate.net"
}

data "template_file" "syllo_config" {
  template = file("${path.module}/user_files/syllo.conf")

  vars = {
    syllo_server_url = local.server_url_string
  }
}

# Definition ssh key from variable
resource "hcloud_ssh_key" "user" {
  count      = length(var.public_ssh_key_name) == 0 && length(var.public_ssh_key) == 0 ? 0 : 1
  name       = var.public_ssh_key_name
  public_key = var.public_ssh_key # this can be changed to use files: file("~/.ssh/id_rsa.pub")
}

# or from existing keys already on cloud
data "hcloud_ssh_keys" "all_keys" {}
