#!/bin/bash
################################################################################
# Script for installing kubernetes on Ubuntu  16.04 and 18.04 
# Author: OmarAbdalhamid Omar
# Mail : o.abdalhamid@zinad.net
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

printf "\n  Step 1/7 -- Update Ubuntu and install [ transport-https  // ca-certificates  // Git // Curl //  software-properties-common  ]...\n\n"

sudo apt-get update -y
sudo apt-get install apt-transport-https -y
sudo apt-get install ca-certificates -y
sudo apt-get install curl -y
sudo apt-get install git -y
sudo apt-get install wget  -y
sudo apt-get install software-properties-common -y
sudo apt install ntp -y
sudo apt install libltdl7 -y
sudo service ntp start
sudo systemctl enable ntp

printf "Step 2/7 --  Install [ Docker 19.03   ]...\n\n"

# Install Docker CE
### Add Docker official GPG key
sudo su -c 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -'

### Add Docker apt repository.
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

## Install Docker CE.
sudo apt-get update -y
sudo apt-get install containerd.io=1.2.10-3 -y
sudo apt-get install "docker-ce=5:19.03.4~3-0~ubuntu-$(lsb_release -cs)" -y
sudo apt-get install "docker-ce-cli=5:19.03.4~3-0~ubuntu-$(lsb_release -cs)"  -y

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

curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-'uname -s'-'uname -m' >/tmp/docker-machine
sudo chmod +x /tmp/docker-machine
sudo cp /tmp/docker-machine /usr/local/bin/docker-machine


sudo usermod -aG docker "${USER}"


sudo service docker start
sudo systemctl enable docker 

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker

printf "\n Step 3/7 --  Add Kubernetes Network file   ]...\n\n"

sudo wget https://raw.githubusercontent.com/omarabdalhamid/Kubernetes-install/master/kube-network.yaml

sudo wget https://raw.githubusercontent.com/omarabdalhamid/Kubernetes-install/master/dashboard.yaml 

printf "\n Step 4/7 --  Install Kubeadm && Kubelete && Kubectl    ]...\n\n"

sudo apt-get update 
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo su -c 'cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF'
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

printf " \n Step 5/7 --  Start Kubernetes Cluster    ]... \n\n"

sudo kubeadm init --token=102952.1a7dd4cc8d1f4cc5 --kubernetes-version "$(kubeadm version -o short)"

sudo  mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u):$(id -g)" "$HOME"/.kube/config
export KUBECONFIG=$HOME/admin.conf

sleep 30

sudo kubectl taint nodes --all node-role.kubernetes.io/master-

printf "\n Step 6/7 --  Create  Kubernetes Network  CoreDNS   ]...\n\n"

sudo kubectl apply -f kube-network.yaml

sudo kubectl apply -f dashboard.yaml

printf "\n Step 7/7 --  Check Kubenetes Cluster Info   ]...\n\n"

sudo kubectl cluster-info

sleep 60
check_dns=$(curl -s -o /dev/null -w "%{http_code}" localhost:6443)
check_dashboard=$(curl -s -o /dev/null -w "%{http_code}" localhost:31000)

if [ "$check_dns" -eq 400 ] && [ "$check_dashboard" -eq 400  ]
    then
       echo "kubernetes cluster works fine "
       echo "Run Zisoft Deploy script here"
    else 
       echo "Error : Kubernetes Installation"
fi

printf "\n Done \n\n"
