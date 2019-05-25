# Kubernetes Gluster cluster set-up tools

This setup is based on master and nodes that are running Debian Stretch. 2GB of RAM is the minimum recommended instance size for both types.


## Setup Kubernetes master (~3 mins)

Copy `setup_master.sh` to master and run it. You'll need to find the private network address of the node to determine which CIDR to use for your cluster network. Look for token and CA cert hash at the end as you'll need them to set up client.

    $ chmod +x setup_kubernetes_master.sh
    $ CIDR=50.158.0.0/16 ./setup_kubernetes_master.sh


## Setup Kubernetes client (~2 mins)

Copy `setup_node.sh` to each node and run the following, substituting your own environment variables. Note that the master's tokens only last for 24 hours and you'll need to generate a new one after that time.

    $ chmod +x setup_kubernetes_node.sh
    $ KUBERNETES_MASTER_IP=1.2.3.4 KUBERNETES_TOKEN=5b8p95.7fsn063n211s4qcp KUBERNETES_CA_CERT_HASH=sha256:86da1a669255541a77e6c8e4750cf8dd91bf302c71e00efd049c694f4d13f521 ./setup_kubernetes_node.sh


From the master machine you should be able to list nodes connected like this.

    $ kubectl get nodes
    NAME                STATUS   ROLES    AGE     VERSION
    kubernetes-master   Ready    master   3h45m   v1.14.2
    kubernetes-node-1   Ready    <none>   3h31m   v1.14.2
    kubernetes-node-2   Ready    <none>   50s     v1.14.2
