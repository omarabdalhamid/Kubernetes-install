#!/bin/bash
################################################################################
# Script for installing kubernetes on Ubuntu  16.04 and 18.04 
# Author: OmarAbdalhamid Omar
# Mial : o.abdalhamid@zinad.net
# Mob : +0201111095001
#-------------------------------------------------------------------------------
# This script will install Kubernetes on your Ubuntu 18.04 server. I
#-------------------------------------------------------------------------------
# Make a new file:
# sudo nano Kubernetes-install.sh
# Place this content in it and then make the file executable:
# sudo chmod +x Kubernetes-install.sh
# Execute the script to install Kubernetes :
# ./Kubernetes-install.sh
################################################################################

#Sets up colored text options
RED='\033[37;41m'
GREEN='\033[30;42m'
YELLOW='\033[30;43m'
NC='\033[0m'

printf "\n${YELLOW}Step 1/7 -- Update Ubuntu and install [ transport-https  // ca-certificates  // Git // Curl //  software-properties-common  ]...${NC}\n\n"

sudo apt-get update -y

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    git \
    wget \
    software-properties-common -y

sudo apt install ntp -y

sudo apt install libltdl7 -y

sudo service ntp start
sudo systemctl enable ntp

#curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - \
#    && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" \
#    && sudo apt-get update \
#    && sudo apt-get install docker-ce=18.03.1~ce-0~ubuntu -yq

printf "\n${YELLOW}Step 2/7 --  Install [ Docker 19.03   ]...${NC}\n\n"

# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS

### Add Docker’s official GPG key
sudo su -c 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -'

### Add Docker apt repository.
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

## Install Docker CE.
sudo apt-get update -y
sudo apt-get install \
  containerd.io=1.2.10-3 \
  docker-ce=5:19.03.4~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.4~3-0~ubuntu-$(lsb_release -cs)  -y

# Setup daemon.
sudo  su -c 'cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF'

sudo mkdir -p /etc/systemd/system/docker.service.d

sudo curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && \
chmod +x /tmp/docker-machine && \
sudo cp /tmp/docker-machine /usr/local/bin/docker-machine

sudo usermod -aG docker ${USER}

sudo service docker start
sudo systemctl enable docker 

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker

printf "\n${YELLOW}Step 3/7 --  Add Kubernetes Network file   ]...${NC}\n\n"

printf "\n${YELLOW}Step 4/7 --  Install Kubeadm && Kubelete && Kubectl    ]...${NC}\n\n"

sudo apt-get update 
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo su -c 'cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF'
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

printf "\n${YELLOW}Step 5/7 --  Start Kubernetes Cluster    ]...${NC}\n\n"

sudo kubeadm init --token=102952.1a7dd4cc8d1f4cc5 --kubernetes-version $(kubeadm version -o short)

sudo  mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/admin.conf

sleep 1m

sudo kubectl taint nodes --all node-role.kubernetes.io/master-

printf "\n${YELLOW}Step 6/7 --  Create  Kubernetes Network  && CoreDNS   ]...${NC}\n\n"

sudo wget https://raw.githubusercontent.com/omarabdalhamid/Kubernetes-install/master/kube-network.yaml

sudo wget https://raw.githubusercontent.com/omarabdalhamid/Kubernetes-install/master/dashboard.yaml 

sudo kubectl apply -f kube-network.yaml

sudo kubectl apply -f dashboard.yaml

printf "\n${YELLOW}Step 7/7 --  Check Kubenetes Cluster Info   ]...${NC}\n\n"

sudo kubectl cluster-info

printf "${GREEN}Done!${NC}\n\n"
