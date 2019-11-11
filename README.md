# Kubernetes-install
Kubeadm for Kubernetes-installation

Master Installation

wget https://raw.githubusercontent.com/omarabdalhamid/Kubernetes-install/master/kmaster.sh  && sh kmaster.sh

wget https://raw.githubusercontent.com/omarabdalhamid/Kubernetes-install/master/kube-network.yaml && kubectl apply -f kube-network.yaml

wget https://raw.githubusercontent.com/omarabdalhamid/Kubernetes-install/master/dashboard.yaml  && kubectl apply -f dashboard.yaml

cat <<EOF | kubectl create -f - 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
EOF


Node Installation

wget https://raw.githubusercontent.com/omarabdalhamid/Kubernetes-install/master/knode2.sh  && sh knode2.sh
