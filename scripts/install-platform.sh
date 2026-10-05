#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLATFORM_DOMAIN="${PLATFORM_DOMAIN:-dev.local}"
STORAGE_CLASS="${STORAGE_CLASS:-local-path}"
kubectl cluster-info >/dev/null
helm repo add jenkins https://charts.jenkins.io 2>/dev/null || true
helm repo add harbor https://helm.goharbor.io 2>/dev/null || true
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube 2>/dev/null || true
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo add grafana-community https://grafana-community.github.io/helm-charts 2>/dev/null || true
helm repo add grafana https://grafana.github.io/helm-charts 2>/dev/null || true
helm repo update
for ns in scm ci registry quality gitops observability; do
  kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply -f -
done
helm upgrade --install forgejo oci://code.forgejo.org/forgejo-helm/forgejo -n scm -f "$ROOT/templates/forgejo/values.yaml" --set global.storageClass="$STORAGE_CLASS" --set ingress.enabled=false
helm upgrade --install jenkins jenkins/jenkins -n ci -f "$ROOT/templates/jenkins/values.yaml" --set controller.ingress.hostName="jenkins.$PLATFORM_DOMAIN" --set persistence.storageClass="$STORAGE_CLASS"
helm upgrade --install harbor harbor/harbor -n registry -f "$ROOT/templates/harbor/values.yaml" --set expose.type=clusterIP --set persistence.persistentVolumeClaim.registry.storageClass="$STORAGE_CLASS"
helm upgrade --install sonarqube sonarqube/sonarqube -n quality -f "$ROOT/templates/sonarqube/values.yaml" --set persistence.storageClass="$STORAGE_CLASS"
helm upgrade --install argocd argo/argo-cd -n gitops -f "$ROOT/templates/argocd/values.yaml"
helm upgrade --install metrics prometheus-community/kube-prometheus-stack -n observability -f "$ROOT/templates/observability/prometheus-values.yaml" --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName="$STORAGE_CLASS" --set grafana.persistence.storageClassName="$STORAGE_CLASS"
helm upgrade --install loki grafana-community/loki -n observability -f "$ROOT/templates/observability/loki-values.yaml"
helm upgrade --install alloy grafana/alloy -n observability -f "$ROOT/templates/observability/alloy-values.yaml"
echo "Installed starter releases. Inspect pod events/PVCs and complete product setup before use."
