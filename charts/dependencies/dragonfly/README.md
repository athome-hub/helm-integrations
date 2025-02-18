# Dragonfly (Redis) cluster

Provide a redis compatible cluster using dragonfly.

## Usage

Dependencies configured in the Helm chart as:

```yaml
dependencies:
  - name: dragonfly-cluster
    version: 0.1.0
    repository: oci://ghcr.io/athome-hub/helm-integrations
    alias: dragonfly
```

### Configuration

In the application chart you can configure the values for the db as follows:

```yaml
dragonfly:
  name: application # Application name
  instances: 3 # Number of instances, defaults to 3
```

### extraArgs

Some applications might require additional arguments to be passed to the cluster, this can be done using the `extraArgs` key. 

```yaml
extraArgs: 
  - --default_lua_flags
  - allow-undeclared-keys
```

### Application redis connection string

The redis host is going to be available at `<name>-dragonfly`