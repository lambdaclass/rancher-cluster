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

You should then apply the manifests in the `k8s-manifests` folder and initialize Helm.

```
$> kubectl apply -f k8s-manifests/ --recursive
namespace/cert-manager created
serviceaccount/tiller created
clusterrolebinding.rbac.authorization.k8s.io/tiller created

$> helm init --service-account tiller --history-max 200
$HELM_HOME has been configured at /Users/bob/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.
```

Next, we install `cert-manager`:

```
$> kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml
customresourcedefinition.apiextensions.k8s.io/certificates.certmanager.k8s.io created
customresourcedefinition.apiextensions.k8s.io/certificaterequests.certmanager.k8s.io created
customresourcedefinition.apiextensions.k8s.io/challenges.certmanager.k8s.io created
customresourcedefinition.apiextensions.k8s.io/clusterissuers.certmanager.k8s.io created
customresourcedefinition.apiextensions.k8s.io/issuers.certmanager.k8s.io created
customresourcedefinition.apiextensions.k8s.io/orders.certmanager.k8s.io created

$> helm repo add jetstack https://charts.jetstack.io
"jetstack" has been added to your repositories

$> helm repo update
Hang tight while we grab the latest from your chart repositories...
...Skip local chart repository
...Successfully got an update from the "jetstack" chart repository
...Successfully got an update from the "stable" chart repository

$> helm install \
    --name cert-manager \
    --namespace cert-manager \
    --version v0.9.1 \
    jetstack/cert-manager
```

Now we install the stable version of Rancher. You will need to provide the hostname of your load balancer and a valid email for Let's Encrypt.

```
$> helm install rancher-stable/rancher \
    --name rancher \
    --namespace cattle-system \
    --set hostname=yourhostname.com \
    --set ingress.tls.source=letsEncrypt \
    --set letsEncrypt.email=youremail@example.org
```

Once the cluster is properly setup, follow the [guides](docs/README.md) to install the different apps.
