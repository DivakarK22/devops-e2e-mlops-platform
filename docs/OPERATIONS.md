# Operations and production checklist

## First run

1. Install K3s or select a Kubernetes context; install `kubectl` and Helm 3.
2. Review chart values and change every `CHANGE_ME`/sample hostname. Create namespaces/secrets and configure TLS before exposing ingress.
3. Run `scripts/install-platform.sh`, then inspect pod events and PVC status. Pin reviewed chart and application versions for repeatable environments.
4. Finish Forgejo and Harbor web setup. Create scoped Harbor robot and SonarQube tokens and add Jenkins credentials. Create a Jenkins Multibranch Pipeline with the sample [`Jenkinsfile`](../templates/application/Jenkinsfile).
5. Create a distinct GitOps repository, place deployment manifests at the path Argo CD watches, and grant it read access. Jenkins should open a reviewed GitOps change with the immutable image tag; Argo CD reconciles the merged change.

## HA and scaling

- K3s: three or five server nodes with embedded etcd, stable API load balancer, reliable disks, off-node snapshots and tested restore. Add agents for workload capacity.
- Jenkins: one controller, persistent home, tested backups/restore; scale only isolated Kubernetes agents. Controller replacement causes downtime while it recovers.
- Argo CD: starter enables redundant stateless services and Redis HA. Verify chart support and spread pods across nodes.
- Prometheus/Alertmanager/Grafana: requested replicas alone do not create durable HA. Use multi-node storage, anti-affinity, compatible remote-write/long-term retention if needed, shared Grafana config and alert routing.
- Loki: local filesystem template is single replica. Production requires microservices mode, external object storage, replication and failure-domain spread.
- Forgejo, Harbor and SonarQube: configure supported external PostgreSQL, object/file storage, backups and each product's documented replica support before adding replicas.

## Security and lifecycle

Use TLS and authentication on every exposed endpoint; keep secrets out of Git. Use RBAC-limited robot accounts and Jenkins agent service accounts. Do not let untrusted pull requests access release credentials. Pin container/chart/plugin versions, review upgrade notes, scan images and schedule backups. Test recovery rather than treating a successful backup job as proof.
