# Harbor OCI registry

Upstream Helm starter uses cluster-internal exposure and Trivy. Replace the sample admin password with a secret at install time. Configure externalURL, TLS and trusted CA certificates before CI access. Create a scoped robot account and store it in Jenkins credentials. Production needs external HA PostgreSQL/Redis, durable object storage, replication, retention and backups; internal stateful components and local-path PVCs are not HA. [Harbor documentation](https://goharbor.io/docs/).
