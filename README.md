# Open source DevOps platform on K3s

A Git to production reference platform built from open source products. K3s and Docker are supported as local runtimes; the Kubernetes path is the complete, repeatable deployment. Product configuration starters live in [`templates/`](templates/).

## Platform choices

| Stage | Product | Role |
|---|---|---|
| Source control | [Forgejo](https://forgejo.org/) | Git hosting, pull requests and webhooks |
| CI | [Jenkins](https://www.jenkins.io/) | Pipeline orchestration; ephemeral Kubernetes agents scale with workload |
| Image registry | [Harbor](https://goharbor.io/) | OCI images, scanning integration and replication |
| Quality and security | [SonarQube Community Build](https://www.sonarsource.com/products/sonarqube/community/) + [Trivy](https://trivy.dev/) | Static analysis and image/filesystem vulnerability scanning |
| CD | [Argo CD](https://argo-cd.readthedocs.io/) | GitOps deployment and drift reconciliation |
| Runtime | [K3s](https://k3s.io/) | Lightweight Kubernetes |
| Metrics and dashboards | [Prometheus Operator + Grafana](https://prometheus-operator.dev/) | Metrics, alerting and dashboards |
| Logs | [Loki](https://grafana.com/oss/loki/) + [Grafana Alloy](https://grafana.com/oss/alloy/) | Log collection, storage and querying |

All listed products are open source. Use the Community Build edition where a vendor also offers paid editions. The manifests are starter templates, not hardened production releases: configure secrets, TLS, backups, storage classes, resource limits and versions for your environment before exposing services.

## Topology and availability

For local evaluation, use one K3s node (or Docker Compose for Forgejo only). For cluster HA use **three or more K3s server nodes with embedded etcd**, an odd server count, stable API registration address/load balancer, and separate agent nodes for workloads. Use reliable SSD-backed storage and test etcd and volume restore procedures.

Jenkins has a single controller in this open source design. Jenkins does not provide an active-active controller; its controller home and queue are not safe to share between live controllers. The chart configures one controller with persistent storage and multiple on-demand Kubernetes agents. For controller recovery, use scheduled, tested backups of `$JENKINS_HOME` and restore to a replacement pod. This provides agent/build capacity scaling and recoverability, **not zero-downtime controller HA**. Keep controller availability separate from K3s control-plane HA.

Prometheus/Grafana and Loki can run multiple replicas, but actual HA requires replicated/persistent storage and anti-affinity across independent nodes. Loki production microservices mode requires an external object store (for example, an independently operated S3-compatible open source store such as MinIO); the single-binary local template is for evaluation. Harbor, Forgejo and SonarQube HA likewise need external PostgreSQL, shared object storage and supported replica configurations; these templates default to a simple local footprint and call out the production boundary.

## Quick start: local K3s

Prerequisites: Linux, `kubectl`, Helm 3, and a running K3s cluster. On a single Linux machine, install K3s using the [official instructions](https://docs.k3s.io/quick-start). The bundled Traefik and local-path storage are fine for a lab, not a multi-node production design.

```sh
kubectl get nodes
./scripts/install-platform.sh
```

The installer adds Helm repositories and installs the platform components with the values under `templates/`. Set `PLATFORM_DOMAIN` (defaults to `dev.local`) and `STORAGE_CLASS` (defaults to `local-path`) before running. Review the script and values first; replace all sample credentials and provide TLS before network exposure. It does not automatically configure product-to-product credentials or create your applications.

Access locally with port forwards (in separate terminals):

```sh
kubectl -n scm port-forward svc/forgejo-http 3000:3000
kubectl -n ci port-forward svc/jenkins 8080:8080
kubectl -n registry port-forward svc/harbor 80:80
kubectl -n gitops port-forward svc/argocd-server 8081:443
kubectl -n observability port-forward svc/kube-prometheus-stack-grafana 3001:80
```

Service names may vary by chart release; confirm with `kubectl -n <namespace> get svc`. Initialize Forgejo and Harbor in their web setup, create credentials as Kubernetes Secrets, then configure the Jenkins credentials and Argo CD repository access. Do not commit live credentials.

## Git to deployment flow

1. Create a repository in Forgejo from [`templates/application/`](templates/application/) and add the sample `Jenkinsfile` and `Dockerfile`.
2. Configure Forgejo webhook to Jenkins (`/forgejo-webhook/post`) and add a Jenkins Multibranch Pipeline pointed at that repository. Create Jenkins credentials for Forgejo, Harbor, and SonarQube; install the plugins listed in [`templates/jenkins/plugins.txt`](templates/jenkins/plugins.txt).
3. On pull requests, Jenkins checks out the commit, runs tests, SonarQube analysis and Trivy filesystem scan. On the main branch it builds an immutable commit-tagged image, scans it, and pushes it to Harbor.
4. Update the image tag in the GitOps repo's deployment manifest. Argo CD watches that repo and syncs the application to K3s. For production, require review/approval for promotion and use separate environments/repos.
5. Alloy collects cluster and workload logs for Loki; Prometheus scrapes metrics; Grafana dashboards and alerts provide operational visibility.

See [`docs/OPERATIONS.md`](docs/OPERATIONS.md) for setup, HA boundaries, backup and upgrade guidance.

## Product template index

Each directory is a starting configuration for that product. Apply only after reviewing its README and adapting versions/storage/credentials.

- [`templates/k3s`](templates/k3s) – single node and HA server bootstrap
- [`templates/forgejo`](templates/forgejo) – Git source control
- [`templates/jenkins`](templates/jenkins) – Jenkins controller and scalable agents
- [`templates/harbor`](templates/harbor) – container registry
- [`templates/sonarqube`](templates/sonarqube) – code quality
- [`templates/trivy`](templates/trivy) – vulnerability scan job
- [`templates/argocd`](templates/argocd) – GitOps CD
- [`templates/observability`](templates/observability) – Prometheus, Grafana, Loki and Alloy
- [`templates/application`](templates/application) – sample app pipeline and Kubernetes deployment

