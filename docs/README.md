# App guides

After the cluster is up and running, you can install apps using the Rancher UI.  

Click on the `Apps` menu item.

![Apps Menu](img/apps-menu.png)

Then choose `Manage Catalogs`.

![Manage Catalogs](img/manage-catalog.png)

Make sure to enable the Helm catalog.

![Catalogs](img/catalogs.png)

---

First of all, make sure you have installed a `ClusterIssuer`, a `cert manager` resource that will issue TLS certificates from Let's Encrypt.

```yaml
# cluster-issuer.yml
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: default
spec:
  acme:
    email: mail@example.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

```
$> kubectl apply -f cluster-issuer.yml
```

From the catalog, we will install the following apps:

- [Prometheus & Grafana](monitoring.md)
- [StorageOS](storageos.md)
- [Docker registry](docker-registry.md)
- [Drone CI](drone.md)
