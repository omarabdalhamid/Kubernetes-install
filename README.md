# Kubernetes-install
Kubeadm for Kubernetes-installation

Master Installation

wget https://raw.githubusercontent.com/omarabdalhamid/Kubernetes-install/master/kmaster.sh  && sh kmaster.sh

wget https://raw.githubusercontent.com/omarabdalhamid/Kubernetes-install/master/kube-network.yaml && kubectl apply -f kube-network.yaml

wget https://raw.githubusercontent.com/omarabdalhamid/Kubernetes-install/master/dashboard.yaml  && kubectl apply -f dashboard.yaml


Node Installation

wget https://raw.githubusercontent.com/omarabdalhamid/Kubernetes-install/master/knode2.sh  && sh knode2.sh
