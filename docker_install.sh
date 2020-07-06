
printf "\n  Step 1/7 -- Update Ubuntu and install [ transport-https  // ca-certificates  // Git // Curl //  software-properties-common  ]...\n\n"

sudo apt-get update -y

sudo apt-get install apt-transport-https -y
sudo apt-get install ca-certificates -y
sudo apt-get install curl -y
sudo apt-get install git -y
sudo apt-get install wget  -y
sudo apt-get install software-properties-common -y

sudo apt install ntp -y
sudo apt install npm -y
sudo apt install libltdl7 -y

sudo service ntp start
sudo systemctl enable ntp

printf "Step 2/7 --  Install [ Docker 19.03   ]...\n\n"

# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS

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
sudo apt install docker-compose

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker
