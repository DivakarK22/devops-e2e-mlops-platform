# Trivy scanner

The sample Job scans an image; the application pipeline also runs Trivy in ephemeral Jenkins agents. Pin Trivy's image version, configure vulnerability DB egress/cache, and define reviewed exception policy. A nonzero exit fails on HIGH/CRITICAL findings. Avoid mounting the host Docker socket; use a rootless image builder such as BuildKit/Kaniko in restricted pods for production.
