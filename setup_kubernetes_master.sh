#!/bin/bash

if [[ -z "${CIDR}" ]]; then
  echo "CIDR environment variable is undefined"
  exit 1
else
  CIDR="${CIDR}"
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

# Initialise cluster
kubeadm init --pod-network-cidr=${CIDR}

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico for pod networking
kubectl apply -f https://docs.projectcalico.org/v3.7/manifests/calico.yaml
kubectl taint nodes --all node-role.kubernetes.io/master-

# Print the token and CA cert hash for convenience
kubeadm token list
CA_HASH=`openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'`
echo "sha256:$CA_HASH"
