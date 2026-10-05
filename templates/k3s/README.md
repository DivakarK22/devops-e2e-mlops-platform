# K3s runtime

For a lab, one server node is enough. For HA, bootstrap server 1 with `--cluster-init`, then join at least two additional server nodes using `--server https://k3s-api.example.internal:6443` and the same token/config. Put a TCP load balancer/VIP in front of server nodes; agents and clients use that stable address. Keep embedded-etcd server count odd. Add agent nodes labeled/tainted for CI workloads.

Back up etcd snapshots off-node and periodically test restore. Embedded etcd needs inter-server TCP 2379/2380; API clients need 6443. Use real DNS/TLS and supported CSI storage for multi-node persistent workloads. References: [HA embedded etcd](https://docs.k3s.io/datastore/ha-embedded), [requirements](https://docs.k3s.io/installation/requirements).
