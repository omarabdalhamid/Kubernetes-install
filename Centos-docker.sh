printf "\n  Step 1/7 -- Update CENTOS and install [  container-selinux // device-mapper-persistent-data l //vm2     ]...\n\n"

sudo wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
sudo yum install container-selinux -y

sudo setenforce 0

sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

sudo yum install yum-utils device-mapper-persistent-data lvm2 -y

sudo yum install -y gcc-c++ make -y
curl -sL https://rpm.nodesource.com/setup_12.x | sudo -E bash -
sudo yum install nodejs  -y

printf "S\n\n Step 2/7 --  Install [ Docker 19.03   ]...\n\n"

# Install Docker CE
## Set up the repository
### Install required packages.

### Add Docker repository.
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

## Install Docker CE.
sudo yum update  -y
sudo  yum install containerd.io-1.2.10 docker-ce-19.03.4 docker-ce-cli-19.03.4 -y

## Create /etc/docker directory.
sudo mkdir /etc/docker

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d

# Enable and Restart Docker

sudo systemctl start docker
sudo systemctl daemon-reload
sudo systemctl enable docker.service
sudo systemctl restart docker
