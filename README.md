# centos-atomic-k8s

Ansible project for deploying containerized Kubernetes master services on Centos Atomic Host 7.

On the Atomic host create a passwordless 'deploy' user with sudo privileges. eg;
```
# useradd deploy
# passwd deploy
# visudo
```
In visudo add the line:
```
deploy  ALL=(ALL)       NOPASSWD: ALL
```
Update the 'inventory' file with your IP addresses or DNS names and run the playbook.
```
ansible-playbook -i inventory atomic-master-pre.yml
```
After successful completion, you can run the ansible scripts [available here](https://github.com/kubernetes/contrib/tree/master/ansible)

Optionally, if you want to enable http access to the API server (or connect via the Kubernetes dashboard) on port 8080 run:
```
ansible-playbook -i inventory atomic-master-post.yml
```
