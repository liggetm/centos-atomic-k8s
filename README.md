# centos-atomic-k8s

Ansible project for deploying containerized Kubernetes services on Centos Atomic Host 7 host systems.  This is simply a wrapper to the upstream Kubernetes deployment scripts [available here](https://github.com/kubernetes/contrib/tree/master/ansible).  It will prepare the Atomic host system for Kubernetes, deploy a Kubernetes cluster and optionally install a Kubernetes dashboard with insecure access on the master on TCP port 8080.

## Pre-Reqs and setup

On each Atomic host create a passwordless 'deploy' user with sudo privileges. eg;
```
# useradd deploy
# passwd deploy
# visudo
```

In visudo add the line:
```
deploy  ALL=(ALL)       NOPASSWD: ALL
```

---
**NOTE:**
If you get warnings about missing locales when logging on to the Atomic host e.g. en_GB.UTF-8 use `export LC_ALL="en_US.UTF-8"`

---

Now update the `inventory` file with your IP addresses or DNS names and, if necessary, your ansible deployment user. eg;
```
[masters]
192.168.1.1 ansible_connection=ssh ansible_user=deploy

[etcd]
192.168.1.1 ansible_connection=ssh ansible_user=deploy

[nodes]
192.168.1.2 ansible_connection=ssh ansible_user=deploy
```
This project also requires the kubernetes/contrib project - it contains the ansible scripts for the upstream Kubernetes install.  Simply clone the https://github.com/kubernetes/contrib project into the third-party directory. eg;
```
$ git clone https://github.com/kubernetes/contrib.git third-party/contrib
```

## Running

Execute the `deploy-atomic-cluster.sh` from the project directory. eg;
```
$ sh scripts/deploy-atomic-cluster.sh
```

Optionally, to enable insecure HTTP access to the Kubernetes API server and install the Kubernetes dashboard pass the `-d` option:
```
$ sh scripts/deploy-atomic-cluster.sh -d
```
