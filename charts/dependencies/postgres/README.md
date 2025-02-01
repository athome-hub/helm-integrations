# Postgres connection 

Provides a database that can be used in integrating with another application.

Uses a cluster provided by CNPG operator  

## Packaging

Ensure the project is created in harbor and you're logged into it. Then run the following from within this directory:

- `helm package .`
- `helm push <tar-file> oci://harbor.cicd.home/hub-helm/integrations/connections`

## Usage

Dependencies configured in the Helm chart as:

```yaml
dependencies:
  - name: postgres-cnpg
    version: 0.3.2
    repository: oci://ghcr.io/athome-hub/helm-integrations
    alias: postgres
```

> [!IMPORTANT]  
> **User Secret**  
> Requires a Secret defined in the application chart,
> create a file within the templates directory called `cnpg-user.yaml` with the following content:
> ```yaml
> {{- $password := randAlphaNum 16 -}}
> {{- $endpoint := printf "%s-db-rw" .Values.postgres.name -}}
> {{- $username := .Values.postgres.name -}}
> {{- $database := printf "%s-db" .Values.postgres.name -}}
> {{- $endpoint := printf "%s-db-rw" .Values.postgres.name -}}
> apiVersion: v1
> kind: Secret
> metadata:
>   name: {{ printf "%s-db-user" .Values.postgres.name }}
>   annotations:
>     "helm.sh/hook": pre-install
>     "helm.sh/resource-policy": keep
> type: Opaque
> stringData:
>   username: {{ $username }}
>   password: {{ $password }}
> ```
> The hooks are important in this use case, since db credentials are generated when installed and not updated with each update, which would break the cluster!  

### Configuration

In the application chart you can configure the values for the db as follows:

```yaml
postgres:
  name: application # Application name
  instances: 3 # Number of DB instances, defaults to 3
  storage:
    storageClass: personal # Storage class to use
    size: 1Gi # Define Volume size for DB, defaults to 1Gi
```

#### Backups

Configure the following for backups

```yaml
global:
  cnpgBackup:
    enabled: true
    accessKey: <accessKey>
    secretKey: <secretKey>
    endpointURL: https://s3.backup.nas.athome:9000
    destinationPath: s3://cnpg/athome
    retentionPolicy: 30d
```

This also needs the `apps.core` stack installed to ensure the secret is present.  

> [!CAUTION]  
> It relies on an `app-inter-ca` secret that has a `ca.crt` key in it.  
> This is intended for a minio local cluster, to do proper certificate validation. 

### Application DB connection string

Defining the postgres user secret in the application chart allows you to also define custom postgres connection strings. Below example adds a connection string to the above secret: 

```yaml
...
stringData:
  ...
  appConnection: postgres://{{ $username }}:{{ $password }}@{{ $endpoint }}:5432/{{ $database }}
```

This can then be used as an environment variable in the applciation container definition, in the deployment definition, for example:

```yaml
apiVersion: apps/v1
kind: Deployment
...
spec:
  ...
  template:
    ...
    spec:
      containers:
      - name: container
        ...
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: {{ .Values.postgres.name }}-db-user
              key: app_connection
```

The above is a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) snippet, where the `DATABASE_URL` environment variable gets it's value from the postgres user definition.

This is important as it allows random passwords to be generated, increasing the application security.

