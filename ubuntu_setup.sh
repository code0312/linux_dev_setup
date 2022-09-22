#!/bin/bash

# A post-install script for Ubuntu to install developer tools
# To download the file, run:
# curl -LO https://raw.githubusercontent.com/code0312/linux_dev_setup/main/ubuntu_setup.sh
# Give execution access with:
# chmod +x ubuntu_setup.sh

# Constants
GREEN='\033[0;32m'
BLUE='\033[0;94m'
CYAN='\033[0;36m'
NC='\033[0m'

function printC {
    local STR=$1
    local COLOR=$2
    echo -ne $COLOR$STR$NC 
}

# Configs
## Turn off terminal bell
echo "set bell-style none" | sudo tee -a /etc/inputrc > /dev/null
## Turn off LESS (man) bell
export LESS="$LESS -Q"

## Main apps
printC "Updating and installing apps \n" $CYAN
sudo apt update && \
sudo apt upgrade && \
printC "Installing git \n" $CYAN && \
sudo apt install git
printC "Installing neovin \n" $CYAN && \
sudo apt install neovim
printC "Installing snapd \n" $CYAN && \
sudo apt install snapd && \
sudo snap install code --classic && \
\
## Setup Git
printC "Setting up Git \n" $CYAN
printC "Enter Git name: " $BLUE
read gitName && \
git config --global user.name "$gitName" && \
printC "Enter Git email: " $BLUE
read gitEmail && \
git config --global user.email "$gitEmail" && \
printC "Git configured for $gitName, $gitEmail" $GREEN && \
\
## Install and setup docker
sudo apt-get remove docker docker-engine docker.io containerd runc ; \
sudo apt-get update && \
sudo apt-get install ca-certificates curl gnupg lsb-release && \
sudo mkdir -p /etc/apt/keyrings && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt-get update && \
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin && \
sudo service docker start && \
sudo groupadd docker && \
sudo usermod -aG docker $USER && \
newgrp docker && \
sudo systemctl enable docker.service && \
sudo systemctl enable containerd.service && \
sudo echo {"log-driver": "json-file", "log-opts": {"max-size": "10m", "max-file": "3"}} >> /etc/docker/daemon.json && \
## Configuring remote access with systemd unit file
## Manual systemd edit docker.service
mkdir /etc/systemd/system/docker.service.d/
touch /etc/systemd/system/docker.service.d/override.conf
# cat << EOF "[Service]\nExecStart=\nExecStart=/usr/bin/dockerd -H fd:// -H tcp://127.0.0.1:2375" | sudo tee -a /etc/inputrc"
cat << EOF >> /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://127.0.0.1:2375
EOF && \
sudo systemctl daemon-reload && \
sudo systemctl restart docker.service && \
sudo apt install net-tools && \
sudo netstat -lntp | grep dockerd

