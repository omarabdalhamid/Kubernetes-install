#!/bin/bash
apt-get update -y

apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y

apt install ntp -y

service ntp start
systemctl enable ntp

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - \
    && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" \
    && sudo apt-get update \
    && sudo apt-get install docker-ce=18.03.1~ce-0~ubuntu -yq

sudo add-apt-repository universe -y

apt-get install docker-compose -y


curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && \
chmod +x /tmp/docker-machine && \
sudo cp /tmp/docker-machine /usr/local/bin/docker-machine

service docker start

systemctl enable docker 

apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

kubeadm init --token=102952.1a7dd4cc8d1f4cc5 --kubernetes-version $(kubeadm version -o short)

sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf


kubectl taint nodes --all node-role.kubernetes.io/master-
