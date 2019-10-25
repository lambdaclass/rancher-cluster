# Drone CI

To install [Drone](https://drone.io) we will use Helm.

```
$> helm install --name ci --namespace drone -f apps/drone/values.yml stable/drone
```

Some important values that can be configured in `values.yml`:

## Ingress

If you choose to enable ingress, fill in the appropriate values in the `annotations` field and add your Drone hostname.

```yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod

  ## Drone hostnames must be provided if Ingress is enabled
  ##
  hosts:
    - drone.yourhost.com

  ## Drone Ingress TLS configuration secrets
  ## Must be manually created in the namespace
  ##
  tls:
    - secretName: drone-tls
      hosts:
        - drone.yourhost.com
```

## VCS provider

If you are using GitHub, follow [these instructions](https://docs.drone.io/installation/providers/github/) to create an OAuth App and fill in the appropriate values. You can find instructions for other providers in [this link](https://docs.drone.io/installation/providers/).

```yaml
sourceControl:
  ## your source control provider: github,gitlab,gitea,gogs,bitbucketCloud,bitbucketServer
  provider: github
  github:
    clientID: your_client_id
    clientSecretValue: your_client_secret_value
```

## Server options

Make sure to enable the `kubernetes` to run pipelines as Kubernetes Jobs instead of using agent pods. You can also choose the protocol Drone will use to communicate with your VCS provider and add a user as administrator. Administrators can create [additional admins](https://docs.drone.io/manage/user/admins/) using the [drone cli](https://docs.drone.io/cli/).

```yaml
server:
  ## If not set, it will be autofilled with the cluster host.
  ## Host shoud be just the hostname.
  host: "drone.lambdaclass.com"

  ## protocol should be http or https
  protocol: https

  ## rpcProtocol for rpc connection to the server should be http or https
  rpcProtocol: http

  ## Initial admin user
  ## Leaving this blank may make it impossible to log into drone.
  ## Set to a valid oauth user from your git/oauth server
  ## For more complex user creation you can use env variables below instead.
  adminUser: admin

  ## Configures Drone to authenticate when cloning public repositories. This is only required
  ## when your source code management system (e.g. GitHub Enterprise) has private mode enabled.
  alwaysAuth: false

  ## Configures drone to use kubernetes to run pipelines rather than agents, if enabled
  ## will not deploy any agents.
  kubernetes:
    enabled: true
```

## Persistence and Metrics

You can choose to save the drone db in persistent storage and to enable monitoring.

```yaml
## Enable scraping of the /metrics endpoint for Prometheus
metrics:
  prometheus:
    enabled: true

## Enable persistence using Persistent Volume Claims
## ref: http://kubernetes.io/docs/user-guide/persistent-volumes/
##
persistence:
  enabled: true

  ## A manually managed Persistent Volume and Claim
  ## Requires persistence.enabled: true
  ## If defined, PVC must be created manually before volume will be bound
  # existingClaim:

  ## rabbitmq data Persistent Volume Storage Class
  ## If defined, storageClassName: <storageClass>
  ## If set to "-", storageClassName: "", which disables dynamic provisioning
  ## If undefined (the default) or set to null, no storageClassName spec is
  ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
  ##   GKE, AWS & OpenStack)
  ##
  storageClass: "fast"
  accessMode: ReadWriteOnce
  size: 3Gi
```

## Drone plugins

Most of the functionality in Drone comes from the different plugins. To enable the [drone-kubernetes](https://github.com/honestbee/drone-kubernetes) you need to create a `Service Account` with the necessary roles.

```
$> kubectl apply -f apps/drone/drone-sa.yml
```

You'll need the token and certificate for your service account. You can get them from the secret for the `drone-deploy` account.

```
$> kubectl -n web get secrets

# Substitute XXXXX below with the correct one from the above command
# Certificate
$> kubectl -n web get secret/drone-deploy-token-XXXXX -o json | jq -r '.data."ca.crt"'

# Token
$> kubectl -n web get secret/drone-deploy-token-XXXXX -o json | jq -r '.data.token' | base64 -d
```

Add them and the api server address as secrets in Drone either using the ui or with `drone-cli`.

```
$> drone secret add --repository org/repo --name kubernetes_server --value $API_SERVER
$> drone secret add --repository org/repo --name kubernetes_token --value $TOKEN
$> drone secret add --repository org/repo --name kubernetes_cert --value $CERT
```

Then you can use the plugin in your Drone pipelines like so:

```yaml
---
kind: pipeline
name: deploy-release

steps:
- name: deploy
  image: jamoroso/drone-kubernetes
  settings:
    deployment: app-deploy
    repo: registry.yourhostname.com/app
    container: app
    tag:
      - latest
    kubernetes_server:
      from_secret: api_server
    kubernetes_token:
      from_secret: kubernetes_token
    kubernetes_cert:
      from_secret: kubernetes_certificate
```
