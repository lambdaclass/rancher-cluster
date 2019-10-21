# App guides

To access the Rancher UI we need a load balancer; we will use [Metallb](https://metallb.universe.tf/). This will provide one inside the cluster. Install it via Helm by


```
$> helm install stable/metallb \ 
    --name metallb \
    --namespace metallb
```

To get it running we need to provide four things. First, a `ClusterIssuer`, a `cert manager` object that will issue TLS certificates from Let's Encrypt.

```yaml
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

Next, a load balancer service within the cluster

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
spec:
  type: LoadBalancer
  loadBalancerIP: nodeIP
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  - name: https
    port: 443
    targetPort: 443
    protocol: TCP
  selector:
    app: ingress-nginx
```

The `loadBalancerIP` entry is optional; it will ensure that the service serves the provided IP, if ommitted kubernetes will just choose a node (this is important because if the node goes down this ip will change).

Third, a `configmap` required by metallb 

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: metallb-config
  namespace: metallb
data:
  config: |
    address-pools:
    - name: loadbalanced
      protocol: layer2
      addresses:
      - IPstart-IPend
```

Make sure the name of this configmap is `metallb-config` and that its namespace matches the one where metallb was installed. The last entry is a range that should cover the IPs you want the load balancer to serve.

Finally, we need an ingress to point to the rancher service

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: rancher-ui
  namespace: cattle-system
  annotations:
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod
    kubernetes.io/ingress.class: "nginx"
  labels:
    app: rancher-ui
spec:
  tls:
  - hosts:
    - yourDomain.com
    secretName: rancher-ui
  rules:
  - host: yourDomain.com
    http:
      paths:
      - path: /
        backend:
          serviceName: rancher
          servicePort: 80
```

To apply these resources:

```
$> kubectl apply -f filename.yaml
```

or place them in a single folder and apply all of them at once

```
$> kubectl apply -f .
```

You can now install apps using the Rancher UI.  

Click on the `Apps` menu item.

![Apps Menu](img/apps-menu.png)

Then choose `Manage Catalogs`.

![Manage Catalogs](img/manage-catalog.png)

Make sure to enable the Helm catalog.

![Catalogs](img/catalogs.png)

---

From the catalog, we will install the following apps:

- [Prometheus & Grafana](monitoring.md)
- [Docker registry](docker-registry.md)
- Drone CI
