# authentik connection 

Provides a proxy that handles authentication with authentik. Ensure [authetik](../../../software/applications/authentik/README.md) is installed in the cluster.  

## Packaging

Ensure the project is created in harbor and you're logged into it. Then run the following from within this directory:

- `helm package .`
- `helm push authentik-proxy-<version>.tgz oci://harbor.cicd.home/hub-helm/integrations/security`

`oci://ghcr.io/athome-hub/helm-integrations`

Configure this chart as a dependency in the application chart as:

```yaml
dependencies:
  - name: authentik-proxy
    version: "1.2.0"
    repository: oci://ghcr.io/athome-hub/helm-integrations
    alias: authentik
    condition: authentik.enabled
```

## Application chart configuration

Following values must be defined in the application chart after this one has been added as a dependency

```yaml
authentik:
  enabled: true
  # Name of the service
  name: "authentik"
  # optional subdomain
  # subDomain: ""
  # DNS rootDoman; used in the ingress
  rootDomain: ""
  # Service to proxy to; with port
  backend: <serice>:<port>
  # Authentik outpost
  outpost: ""
  # Ingress settings
  ingress:
    # Class to use
    class: ""
    # Ingress annotations
    annotations: {}
      # konghq.com/https-redirect-status-code: '301'
      # konghq.com/protocols: https
      # cert-manager.io/cluster-issuer: ai-inter-ca
```

> [!TIP]  
> The hostname that the application will be accessible from, will be defined using the following keys:  
> - name
> - subDomain - optional
> - rootDomain  
> 
> The hostname will have this format if subdomain is specified  
> `name.subDomain.rootDomain`  
> Without the subdomain specified, it will have this format:  
> `name.rootDomain`

> [!IMPORTANT]  
> Ensure the built-in ingress of the application chart is disabled when using the proxy.  
> All traffic going to the application will run through the proxy to enable authentication.  