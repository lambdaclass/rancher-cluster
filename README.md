# Rancher Cluster

## Requirements

- [rke](https://rancher.com/docs/rke/latest/en/installation/)
- [Python 3](https://www.python.org/downloads/)
- [Pipenv](https://pipenv-fork.readthedocs.io/en/latest/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Helm](https://helm.sh)

## Setup

Make sure you fill in the inventory file (`ansible/inventory.ini`) with the ip of the servers that make up the cluster.

## Usage

### Install Ansible

```
$> make init
```

### Prepare nodes

Check if [requirements](https://rancher.com/docs/rke/latest/en/os/) are met and install Docker.

```
$> make prepare
```

### Create Rancher config

Fill with appropriate values for your cluster.

```
$> make config
```

### Setup cluster

```
$> make cluster
```

After the install process finishes, copy the kubectl config file to `$HOME/.kube/config`:

```
$> cp kube_config_cluster.yml ~/.kube/config
```

You should have access to the cluster via `kubectl`:

```
$> kubectl cluster-info
Kubernetes master is running at https://192.168.0.101:6443
coredns is running at https://192.168.0.101:6443/api/v1/namespaces/kube-system/services/coredns:dns/proxy
```

