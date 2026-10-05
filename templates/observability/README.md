# Metrics, dashboards and logs

Prometheus Operator installs Prometheus, Alertmanager, Grafana and Kubernetes dashboards. Values request two Prometheus replicas and three Alertmanager replicas with persistent volumes; redundancy requires independent nodes and reliable CSI storage. Grafana has two replicas; provision shared dashboards/datasources rather than pod-local edits. Change its sample admin password.

Loki values are single-binary with local filesystem for a lab. Production HA requires Loki microservices mode, external object storage, replication and zone-aware placement; follow Grafana Community chart docs. Alloy runs as a DaemonSet and ships pod logs to Loki. Restrict Alloy permissions and Loki ingress. Configure Grafana Loki datasource at `http://loki-gateway.observability.svc.cluster.local`.
