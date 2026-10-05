# Argo CD continuous delivery

Chart values enable multiple stateless API/repo-server/ApplicationSet replicas and Redis HA. Configure repository credentials using Argo CD Secrets or deploy keys; avoid plaintext credentials in Git. Bootstrap from [`../application/argocd-application.yaml`](../application/argocd-application.yaml). Use a separate GitOps repo and restricted project destinations. Add TLS/ingress and SSO before production.
