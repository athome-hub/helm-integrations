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
    version: 1.3.1
    repository: oci://ghcr.io/athome-hub/helm-integrations
    alias: authentik
    condition: authentik.enabled
```

## Application chart configuration

Following values must be defined in the application chart after this one has been added as a dependency

```yaml
authentik:
  # Name of the service
  name: "authentik"
  # Service to proxy to; with port
  backend: <serice>:<port>
  # Authentik outpost
  outpost: ""
```

The application ingress can be switched to point to the authentik service.  
This will be available at `{{ authentik.name }}-auth` and the port.name: `http`.
