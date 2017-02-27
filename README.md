# centos-atomic-k8s

Ansible project for deploying containerized Kubernetes services on Centos Atomic Host 7 host systems.  This is simply a wrapper to the upstream Kubernetes deployment scripts [available here](https://github.com/kubernetes/contrib/tree/master/ansible).  It will prepare the Atomic host system for Kubernetes, deploy a Kubernetes cluster and optionally install a Kubernetes dashboard with insecure access on the master on TCP port 8080.  It will also output a valid kubectl configuration which can be saved in a ~/.kube/config file.

## Pre-Reqs and Setup

Requirements for the system which will run the installation:
- bash _(for running the installation script)_
- ansible > version 2.1 _(for running the ansible playbooks)_
- kubectl > version 1.3.0 _(optional, allows secure CLI access and proxying)_

On each Atomic host create a 'deploy' user with sudo privileges. eg;
```
# useradd deploy
# passwd deploy
# visudo
```
In visudo add the line:
```
deploy  ALL=(ALL)       NOPASSWD: ALL
```
Ensure you have configured password-less SSH to the Atomic hosts. eg;
```
ssh-copy-id deploy@atomic
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
The script will log to the `logs/deploy-atomic-cluster.log` - this is where to go if you find any errors.  You can also watch the log in another terminal using something like `tail -f logs/deploy-atomic-cluster.log`.

At the end of the script, a configuration for Kubectl is listed.  Save this into your ~/.kube/config file for secure connection to the cluster using kubectl.  Once saved it can also be used to proxy the server. eg;
```
kubectl proxy --port=8080 &
```
With the proxy running endpoints will be available. eg; http://localhost:8080/ui

## Ansible Roles

#### Common
Runs on both Kubernetes masters and nodes.  Currently disables SELinux on Atomic - see http://www.projectatomic.io/blog/2017/01/centos-atomic-jan17/ for further info.

#### atomic-master-pre
Runs on Kubernetes masters only.  Installs service definitions files for kube-apiserver, kube-controller-manager and kube-scheduler and reloads the systemd configuration.

#### atomic-master-post
Runs on Kubernetes masters only (after the Kubernetes deploy-cluster script from Kubernetes/contrib/ansible/scripts).  Reconfigures and reloads the Kuberneres API server so that it binds insecurely to port 8080 on the master.  Installs the Kubernetes dashboard if it is not already installed.  Configures the KUBE-FIREWALL to allow access to port 8080.

## Alternatives

To make your Atomic host Kubernetes-capable you can run the ansible `atomic-master-pre.yml` playbook in the normal manner. eg;
```
$ ansible-playbook -i inventory atomic-master-pre.yml
```
To install the Kubernetes dashboard and open port 8080 for the API server use the ansible `atomic-master-post.yml` playbook. eg;
```
$ ansible-playbook -i inventory atomic-master-post.yml
```
