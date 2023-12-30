# klab-base

This repository contains configurations to bootstrap and manage a simple home infrastructure using [k3s](https://k3s.io/) and [Argo CD](https://argo-cd.readthedocs.io/en/stable/).

## Stack

| Tool                                                              | Description                                                       |
| ----------------------------------------------------------------- | ----------------------------------------------------------------- |
| [Ansible](https://ansible.com)                                    | Bare metal provisioning and configuration                         |
| [Argo CD](https://argo-cd.readthedocs.io)                         | GitOps operator for managing cluster                              |
| [K3s](https://k3s.io)                                             | A Kubernetes distribution                                         |
| [kube-prometheus-stack](https://github.com/prometheus-community/) | Prometheus Operator with Grafana dashboards for basic monitoring  |
| [MetalLB](https://metallb.universe.tf/)                           | MetalLB is a load-balancer implementation for bare-metal clusters |
| [ingress-nginx](https://github.com/kubernetes/ingress-nginx)      | An Ingress controller for Kubernetes using NGINX                  |
| [cert-manager](https://cert-manager.io/)                          | X.509 certificate management                                      |

## Getting Started

### Configuring MetalLB

Before delving into the setup process, it is crucial to identify the available IP addresses within our network that can be assigned to MetalLB. To accomplish this, examine the IP address space of your router and utilize the [Visual Subnet Calculator from Sargasso](https://www.davidc.net/sites/default/subnets/subnets.html) tool. This tool will assist you in determining the range of available IPs.

Once you have identified the range, subtract the range used by your router's DHCP server from the resulting range. This updated range can then be utilized by MetalLB and specified in `apps/core/metalb/configs.yaml``.

### Bootstrapping

To initiate the setup, execute the `make bootstrap` command (refer to the example below). This command will manage the installation and configuration of Argo CD, along with the application of the `root`` Application (app of apps).

```sh
GITHUB_PRIVATE_KEY_PATH=./mykey.pem make bootstrap
```

After running the bootstrap command, the following tasks will be automatically performed:

- Argo CD syncs the root app, triggering the synchronization of the core `AppProject` and `ApplicationSet`.
- The ApplicationSet core initiates the sync process for all underlying Apps located in the `apps/` directory.

Once all apps are successfully synchronized, you can access Argo CD through the specified domain name.
