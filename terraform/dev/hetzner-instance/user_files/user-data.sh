#!/bin/bash

# This script is automatically run by root user at the first run of an instance
# and all files and folders it creates will be owned by the user root if not
# specified differently.

# When a this user data script is processed, it is copied to and run from
# /var/lib/cloud/instances/{instance-id}/scripts/part-001
# Remove it after it has finished.

# The initialization output log file will be at /var/log/cloud-init.log and
# /var/log/cloud-init-output.log

set -e

VERSION="1.1"

function end() {
# ALL Filished.
# Removing user-data.sh in case it contains sensitive data
sleep 10
# shellcheck disable=SC2154
rm -f /var/lib/cloud/instances/*/scripts/part-001

echo "---------------------------------------"
echo "ENDING User-Data.sh Sctipt $VERSION"
echo "---------------------------------------"
}

function err() {
end
# Something was wrong - break with the error code 255
echo "$1"
exit 255
}

echo "---------------------------------------"
echo "STARTING User-Data.sh Sctipt $VERSION"
echo "---------------------------------------"

# Setup new user syllo
useradd -m -U -c "Syllo main user" syllo -s "/bin/bash"
# shellcheck disable=SC2154
echo syllo:"${syllo_password}" | chpasswd
printf "%s\n\n%s\n" "# Created by user-data.sh during init time." "syllo   ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/syllo
echo "alias ll='ls -al'" > /home/syllo/.bash_aliases
echo "alias la='ls -A'" >> /home/syllo/.bash_aliases
echo "alias l='ls -CF'" >> /home/syllo/.bash_aliases
chown syllo:syllo /home/syllo/.bash_aliases
rm -f /home/syllo/.bash_logout

# Setup SSH
sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
mkdir -p /home/syllo/.ssh
cp /root/.ssh/authorized_keys /home/syllo/.ssh/authorized_keys
chown -R syllo:syllo /home/syllo/.ssh
systemctl restart sshd.service
su syllo -c "ssh-keygen -f /home/syllo/.ssh/id_rsa -N ''"

# Setup a 4GB swapfile
# https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-debian-10
fallocate -l 4G /swapfile
ls -lh /swapfile || err "Swapfile not created. Exiting the script!."
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

# Update the system packages
apt-get update && apt-get upgrade -y

# install build essential for npm packages and other scripts
apt-get install -y build-essential curl wget git software-properties-common rsync gnupg2 ca-certificates lsb-release apt-transport-https jq vim

# install nginx
echo "deb http://nginx.org/packages/debian $(lsb_release -cs) nginx" | tee /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
#NGINX_KEY="573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62"
#CHECK_KEY=$(apt-key adv --with-colons --with-fingerprint --list-public-keys ABF5BD827BD9BF62 | awk -F: '$1 == "fpr" { print $10 }')
#[ "$NGINX_KEY" = "$CHECK_KEY" ] || exit 255 # break the script if keys do not match !
apt-get update && apt-get install -y nginx
service nginx start

# install certbot for let's encrypt
apt-get install -y python3-acme python3-certbot python3-mock python3-openssl python3-pkg-resources python3-pyparsing python3-zope.interface
apt-get install -y python3-certbot-nginx

# install node.js
curl -sL https://deb.nodesource.com/setup_lts.x | sudo bash -
apt-get install -y nodejs

# install Yarn package manager
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt-get update && apt-get install -y yarn

# install pm2
npm install -g pm2
# pm2 completion install # should be run as a user
# Add pm2 system user so that we are safe from login hacks
useradd -r -c "pm2 service account" pm2
# Stat pm2 service at startup as pm2 user
# "$(which pm2)" startup systemd -u pm2 --hp /home/pm2
# Start the app with; sudo pm2 -u pm2 start app.js
"$(which pm2)" startup systemd -u syllo --hp /home/syllo

# install GitLab runner
curl -sL https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash -
export GITLAB_RUNNER_DISABLE_SKEL=true; sudo -E apt-get install gitlab-runner

# Install Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io
#sudo usermod -aG docker user_name # add current user_name to docker group to be able to run docker withot sudo
usermod -aG docker syllo

# Install Docker-compose
curl -sL "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
# Install compose completion
curl \
    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
    -o /etc/bash_completion.d/docker-compose

apt install -y protobuf-compiler
npm -g install lerna

# Setup work dir for syllo and frontends
mkdir /var/www
chown -R syllo:syllo /var/www

# shellcheck disable=SC2154
echo "${syllo_config}" > /etc/nginx/conf.d/syllo.conf
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.disabled
systemctl restart nginx || err "NGINX Failed to restart with the new config file '/etc/nginx/conf.d/syllo.conf'"

# Configure syllo user with npm access tokens
echo "@syllo:registry=https://gitlab.pannovate.net/api/v4/packages/npm/" > /home/syllo/.npmrc
# shellcheck disable=SC2154
echo "//gitlab.pannovate.net/api/v4/packages/npm/:_authToken=${npm_token}" >> /home/syllo/.npmrc
curl -s https://gitlab.pannovate.net/api/v4/groups/67/projects?access_token="${npm_token}" | jq -c '.[].id' | while read -r id; do echo "//gitlab.pannovate.net/api/v4/projects/$id/packages/npm/:_authToken=${npm_token}"; done >> /home/syllo/.npmrc || true
curl -s https://gitlab.pannovate.net/api/v4/groups/67/subgroups?access_token="${npm_token}" | jq -c '.[].id' | while read -r gid; do curl -s https://gitlab.pannovate.net/api/v4/groups/"$gid"/projects?access_token="${npm_token}" | jq -c '.[].id' | while read -r id; do echo "//gitlab.pannovate.net/api/v4/projects/$id/packages/npm/:_authToken=${npm_token}"; done; done >> /home/syllo/.npmrc || true
sudo chown syllo:syllo /home/syllo/.npmrc

# Configure Syllo project ID 260 with deploy key
# shellcheck disable=SC2154
key_id=$(curl -s --header "PRIVATE-TOKEN: ${gitlab_api_access_token}" "https://gitlab.pannovate.net/api/v4/projects/260/deploy_keys" | jq '.[] | select(.title=="${gitlab_deploy_key}") | .id')
if [ -z "$key_id" ]; then
# shellcheck disable=SC2154
    echo "Key with the name \"${gitlab_deploy_key}\" not found. Adding the key to the GitLab project ID-260 (Syllo)"
    curl -s \
        --request POST --header "PRIVATE-TOKEN: ${gitlab_api_access_token}" --header "Content-Type: application/json" \
        --data "{\"title\": \"${gitlab_deploy_key}\", \"key\": \"$(cat /home/syllo/.ssh/id_rsa.pub)\", \"can_push\": \"false\"}" \
        "https://gitlab.pannovate.net/api/v4/projects/260/deploy_keys/"
    echo
    echo "Check for the key after addittion to Syllo project ID-260"
    echo "Key ID: $(curl -s --header "PRIVATE-TOKEN: ${gitlab_api_access_token}" "https://gitlab.pannovate.net/api/v4/projects/260/deploy_keys" | jq '.[] | select(.title=="${gitlab_deploy_key}") | .id')"
    echo
else
    if [ "$(curl -s --header "PRIVATE-TOKEN: ${gitlab_api_access_token}" "https://gitlab.pannovate.net/api/v4/projects/260/deploy_keys" | jq '.[] | select(.title=="${gitlab_deploy_key}") | .key')" == "$(cat /home/syllo/.ssh/id_rsa.pub)" ]; then
        echo "The same key with the same name ${gitlab_deploy_key} under ID: $key_id already exists in the GitLab project ID-260 (Syllo). Key not added!"
    else
        echo "Another key with the same name ${gitlab_deploy_key} under ID: $key_id already exists in the GitLab project ID-260 (Syllo). Key added!"
        curl -s \
        --request POST --header "PRIVATE-TOKEN: ${gitlab_api_access_token}" --header "Content-Type: application/json" \
        --data "{\"title\": \"${gitlab_deploy_key}\", \"key\": \"$(cat /home/syllo/.ssh/id_rsa.pub)\", \"can_push\": \"false\"}" \
        "https://gitlab.pannovate.net/api/v4/projects/260/deploy_keys/"
    fi
fi

# Add GitLab as a trusted connection
echo "Adding pannovate GotLab as a trusted SSH source"
su syllo -c "ssh-keyscan -H gitlab.pannovate.net >> /home/syllo/.ssh/known_hosts"

# Clone the repository
cd /var/www || err "Cannot cd into /var/www. Exiting script!"
echo "Pulling down the repository."
su syllo -c "git clone git@gitlab.pannovate.net:syllo/syllo.git" || err "Cannot clone the repository"
echo "Checking out ${git-branch} branch"
cd /var/www/syllo || err "Cannot cd into /var/www/syllo. Exiting script!"
su syllo -c "git checkout ${git-branch}" || err "Cannot checkout the branch ${git-branch}"

echo "Install prerequisite packages..."
su syllo -c "yarn"
echo "...and bootstrap the project."
su syllo -c "lerna bootstrap"
echo "Pull and activate required docker services."
su syllo -c "docker-compose -f services.yml up -d"
echo "Starting the initial lerna build."
su syllo -c "lerna run build"
echo "Refreshing / Seeding the database."
su syllo -c "yarn db:refresh"
echo "Start PM2 with syllo processes."
su syllo -c "pm2 start ecosystem.config.js"

printf "\e[0;92m%s\e[0m\n" "Expecting response from 'localhost:10000/is-everything-alright'"
cnt=1 && tmout=10
while [ $cnt -le 5 ]; do
    printf "\e[0;92m%s\e[0m\n" "Running pass no. $cnt"
    printf "\e[0;92m%s\e[0m\n" "Waiting for $tmout seconds" && sleep $tmout # Give services some time to come up
    tmout=$(( tmout + 10 )) # increase wait time
    if curl -s localhost:10000/is-everything-alright > r.json ; then printf "\e[0;92m%s\e[0m\n" "[OK] Server Found!" ; else printf "\e[0;91m%s\e[0m\n" "[ERROR] Server not responding!" && echo && cnt=$(( cnt + 1 )) && continue ; fi
    if [ "$(jq -r .status r.json)" = "ok" ]; then printf "\e[0;92m%s\e[0m\n" "   Server status response \"Status:OK\"" ; else printf "\e[0;91m%s\e[0m\n" "   Server status response \"$(jq -r .status r.json)\"!" && echo && cnt=$(( cnt + 1 )) && continue ; fi
    if [ "$(jq -r '.services | map(values.status) | length' r.json)" -eq 9 ]; then printf "\e[0;92m%s\e[0m" "   Number of listed services 9 - OK!"; else printf "\e[0;91m%s\e[0m\n" "[ERROR] Number of active services reported \"$(jq -r '.| map([.]) | .[1] | .[] | length' r.json)\", but expected 10!" && echo && cnt=$(( cnt + 1 )) && continue ; fi
    printf "     %s\n" "$(jq -r '.services | map_values(. | del(.version) | . = .[])' r.json | sed 's/{//g' | sed 's/}//g')" && echo
    if [ "$(jq -r '.services | map_values(. | del(.version) | . = .[])' r.json | grep -c down)" -eq 0 ]; then printf "\e[0;92m%s\e[0m\n" "[OK] All services seem OK! Deployment was successful" && end; else printf "\e[0;91m%s\e[0m\n" "[ERROR] NOT ALL Services are running!" && echo && cnt=$(( cnt + 1 )) && continue ; fi
done
err "\e[0;91m[ERROR] Deployment was NOT successful! DO A ROLLBACK NOW!\e[0m"
