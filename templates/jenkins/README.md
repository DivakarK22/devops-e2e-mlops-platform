# Jenkins CI

Install with the Jenkins community chart. The controller runs zero executors; Kubernetes plugin agents provide elastic concurrency (cap 50). Tune resource requests, quotas and node pools. Pin controller/agent/plugin versions after validating upgrades.

There is one active controller. Keep its PVC and take consistent off-cluster backups of `$JENKINS_HOME`; rehearse restore. Do not mount one home directory into multiple controllers. Jenkins open source has no active-active controller HA. Isolate agents and credentials because builds execute repository code. Configure Jenkins Credentials, then create a Multibranch Pipeline for the application repo. Official [Kubernetes installation guide](https://www.jenkins.io/doc/book/installing/kubernetes/).
