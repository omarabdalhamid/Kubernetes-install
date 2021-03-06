#!/bin/bash
apt-get update -y

apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y

apt install ntp -y

apt install libltdl7 -y

service ntp start
systemctl enable ntp

#curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - \
#    && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" \
#    && sudo apt-get update \
#    && sudo apt-get install docker-ce=18.03.1~ce-0~ubuntu -yq
sudo  wget https://download.docker.com/linux/ubuntu/dists/bionic/pool/stable/amd64/docker-ce-cli_18.09.0~3-0~ubuntu-bionic_amd64.deb
sudo  dpkg -i  docker-ce-cli_18.09.0~3-0~ubuntu-bionic_amd64.deb
sudo  add-apt-repository universe -y

apt-get install docker-compose -y




curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && \
chmod +x /tmp/docker-machine && \
sudo cp /tmp/docker-machine /usr/local/bin/docker-machine

service docker start

systemctl enable docker 

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


apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubeadm=1.15.1 kubectl=1.15.1 kubelet=1.15.1 kubernetes-cni=0.7.5
apt-mark hold kubelet kubeadm kubectl

