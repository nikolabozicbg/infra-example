output "server_name" {
  value = hcloud_server.server.name
}

output "server_id" {
  value = hcloud_server.server.id
}

output "ip_address" {
  value = hcloud_server.server.ipv4_address
}

output "ssh_key_name" {
  value = length(var.public_ssh_key_name) > 0 ? hcloud_ssh_key.user[0].name : "No SSH Key specified in 'variables.tfvars' file."
}

output "existing_ssh_keys" {
  value = var.use_existing_ssh_keys ? data.hcloud_ssh_keys.all_keys.ssh_keys.*.name : tolist(["No previous keys assigned to this instance"])
}

output "ALL_DONE" {
  value = <<EOT
Acquiring of the resources and Initialization of the environment with needed
software and correct user settings is complete.

NEXT STEPS:
- Add A DNS record for '${local.server_url_string}' pointing to '${hcloud_server.server.ipv4_address}'

- Connect to the instance with:
ssh syllo@${hcloud_server.server.ipv4_address}
	or
ssh syllo@${local.server_url_string}

- Generate token for the GitLab Runner on gitlab.pannovate.net
    <CURRENT_PROJECT_NAME> -> Settings -> Ci/CD -> Runners

- Register and install the group gitlab-runner
cd /var/www/syllo && sudo gitlab-runner register
sudo gitlab-runner stop && sudo gitlab-runner uninstall
sudo gitlab-runner install -d /var/www --user syllo && sudo gitlab-runner start

- Run a deploy from a projects infra repository

- Configure Nginx by running letsEncrypt for `${local.server_url_string}`:
sudo certbot --nginx -d ${local.server_url_string}

- Configure CI and Nginx for Front-End projects.

NOTE:
	To monitor the process, wait approx 1 minute to do a SSH connect and run
	sudo tail /var/log/cloud-init-output.log -f

	After Approx. 10 minutes try
	curl ${hcloud_server.server.ipv4_address}/is-everything-alright
	from the local machine (or remote)
EOT
}

output "inventory" {
  value = [{
    # the Ansible groups to which we will assign the server
    # "groups"           : var.ansibleGroups,
    "name"             : "${hcloud_server.server.name}",
    "env"              : "${var.env}",
    "ip"               : "${hcloud_server.server.ipv4_address}",
    "url"              : "${local.server_url_string}",
    "ansible_ssh_user" : "root",
    "non_root_user"    : "syllo"
    "private_key_file" : "${length(var.public_ssh_key_name) > 0 ? hcloud_ssh_key.user[0].name : "~/.ssh/id_rsa"}"
  }]
}
