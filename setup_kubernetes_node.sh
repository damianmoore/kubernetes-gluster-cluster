#!/bin/bash

if [[ -z "${KUBERNETES_MASTER_IP}" ]]; then
  echo "KUBERNETES_MASTER_IP environment variable is undefined"
  exit 1
else
  KUBERNETES_MASTER_IP="${KUBERNETES_MASTER_IP}"
fi

if [[ -z "${KUBERNETES_TOKEN}" ]]; then
  echo "KUBERNETES_TOKEN environment variable is undefined"
  exit 1
else
  KUBERNETES_TOKEN="${KUBERNETES_TOKEN}"
fi

if [[ -z "${KUBERNETES_CA_CERT_HASH}" ]]; then
  echo "KUBERNETES_CA_CERT_HASH environment variable is undefined"
  exit 1
else
  KUBERNETES_CA_CERT_HASH="${KUBERNETES_CA_CERT_HASH}"
fi


# Install Docker
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
      stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
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
systemctl daemon-reload
systemctl restart docker

# Install Kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl

# Join Kubernetes cluster
kubeadm join ${KUBERNETES_MASTER_IP}:6443 --token ${KUBERNETES_TOKEN} --discovery-token-ca-cert-hash ${KUBERNETES_CA_CERT_HASH}
