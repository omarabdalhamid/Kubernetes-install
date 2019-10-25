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

# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add Docker apt repository.
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

## Install Docker CE.
apt-get update && apt-get install docker-ce=18.06.2~ce~3-0~ubuntu

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker

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

#kubeadm join --discovery-token-unsafe-skip-ca-verification --token=102952.1a7dd4cc8d1f4cc5 172.31.11.255:6443
kubeadm join 192.168.1.202:6443 --token 102952.1a7dd4cc8d1f4cc5 \
    --discovery-token-ca-cert-hash sha256:a3fff3ba00ff9cceefa4dd26ca2a19eee6891a90e9659473cd0ed77cea0e5991 
