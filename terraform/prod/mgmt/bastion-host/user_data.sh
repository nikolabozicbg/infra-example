#!/bin/env bash

# This script is automatically run by root user at the first run of an instance
# and all files and folders it creates will be owned by the user root if not
# specified differently.
# More info: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html

# When a this user data script is processed, it is copied to and run from
# /var/lib/cloud/instances/{instance-id}/. Remove it if creating an AMI image.

# The initialization output log file will be at /var/log/cloud-init.log and
# /var/log/cloud-init-output.log

# Update the system packages
# apt-get update && apt-get upgrade -y
yum update -y
yum update -y ca-certificates
amazon-linux-extras enable epel

# install MongoDB tools
cat > /etc/yum.repos.d/mongodb-org-5.0.repo << EOF
[mongodb-org-5.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc
EOF

yum install -y mongodb-org-tools

yum -y install epel-release curl glibc-devel gcc make patch gcc-c++ git

# install nginx
#yum -y install nginx

# install certbot for let's encrypt
#yum install -y certbot certbot-nginx
#systemctl restart nginx.service

install node.js
curl -sL https://rpm.nodesource.com/setup_lts.x | sudo bash -
yum install -y nodejs

install Yarn package manager
curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
yum -y install yarn

# install pm2
#npm install -g pm2
# pm2 completion install # should be run as a user
# Add pm2 system user so that we are safe from login hacks
#useradd -r -c "pm2 service account" pm2
# Stat pm2 service at startup as pm2 user
#sudo "$(which pm2)" startup systemd -u pm2 --hp /home/pm2
# Start the app with; sudo pm2 -u pm2 start app.js

# Cleaning up everything and free up space taken by orphaned data from disabled or removed repos
yum clean all
rm -rf /var/cache/yum
