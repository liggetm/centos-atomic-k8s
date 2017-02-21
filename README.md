# centos-atomic-k8s

Ansible project for deploying containerized Kubernetes on Centos Atomic Host 7.

On the Atomic host create a 'deploy' user with sudo permissions.  Alternatively configure the remote_user setting in 'atomic-master.yml' to suit your environment.

Review and optionally configure the variable in:
```
roles/atomic-k8s-master/defaults/main.yml
```

Update the 'inventory' file with your IP addresses or DNS names and run the playbook.

```
ansible-playbook -i inventory atomic-master.yml
```
