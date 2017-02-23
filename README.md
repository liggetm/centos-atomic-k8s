# centos-atomic-k8s

Ansible project for deploying containerized Kubernetes services on Centos Atomic Host 7 host systems.  This is simply a wrapper to the upstream Kubernetes deployment scripts [available here](https://github.com/kubernetes/contrib/tree/master/ansible).  It will prepare the Atomic host system for Kubernetes, deploy a Kubernetes cluster and optionally install a Kubernetes dashboard with insecure access on the master on TCP port 8080.

** Pre-Reqs **

On the Atomic hosts create a passwordless 'deploy' user with sudo privileges. eg;
```shell
# useradd deploy
# passwd deploy
# visudo
```

In visudo add the line:
```shell
deploy  ALL=(ALL)       NOPASSWD: ALL
```
Next update the 'inventory' file with your IP addresses or DNS names.

---
**NOTE:**
If you get warnings about missing locales when logging on to the Atomic host e.g. en_GB.UTF-8 use `export LC_ALL="en_US.UTF-8"`

---

** Running **

Execute the following script from the project directory. eg;
```shell
sh scripts/deploy-atomic-cluster.sh
```

Optionally, if you want to enable insecure http access to the Kubernetes API server and install the Kubernetes dashboard pass the `-d` option:
```shell
sh scripts/deploy-atomic-cluster.sh -d
```
