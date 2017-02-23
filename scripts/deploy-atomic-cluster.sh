#!/bin/bash

SCRIPT=$0
SCRIPT_NAME=$(basename $SCRIPT)
INVENTORY_FILE="./inventory"
KUBERNETES_SCRIPT_DIR="./third-party/contrib/ansible/scripts"
KUBERNETES_SCRIPT="deploy-cluster.sh"
KUBERNETES_INVENTORY_DIR="./third-party/contrib/ansible/inventory"

function main() {

  while getopts "dh" option; do
    case $option in
      * ) showUsage
          exit 1;;
      d ) enable_insecure=true;;
      * ) showUsage
          exit 1;;
    esac
  done

  check_deps
  execute_ansible_pre
  execute_k8s_deploy_cluster

  if [ "${enable_insecure}" = "true" ]; then
    execute_ansible_post
  fi
}

function showUsage() {
    cat <<END

    ${SCRIPT_NAME} - Deploy Atomic Cluster

    Usage: ${SCRIPT_NAME} [-d]
           ${SCRIPT_NAME} -h

    -d    optionally starts the K8s API server on insecure port 8080 and installs the K8s Dashboard
    -h    show this usage text

END
    exit 0
}

function check_deps() {
  if [ ! -f "${INVENTORY_FILE}" ]; then
    fatal 'ERROR: Cannot find inventory file in current directory'
  fi

  which -s ansible-playbook || fatal 'ERROR: ansible-playbook not found on path'

  if [ ! -f "${KUBERNETES_SCRIPT_DIR}/${KUBERNETES_SCRIPT}" ]; then
    fatal 'ERROR: Kubernetes contrib project not found in third-party'
  fi

  if [ ! -d "${KUBERNETES_INVENTORY_DIR}" ]; then
    fatal 'ERROR: Cannot find third-party inventory directory'
  fi
}

function execute_ansible_pre() {
  ansible-playbook -i inventory atomic-master-pre.yml
}

function execute_k8s_deploy_cluster() {
  /bin/cp -f ${INVENTORY_FILE} ${KUBERNETES_INVENTORY_DIR} || fatal 'ERROR: Failed to copy inventory file to third-party directory'
  pushd ${KUBERNETES_SCRIPT_DIR} 2>&1
  ./${KUBERNETES_SCRIPT} || fatal 'ERROR: Third-party Kubernetes deploy-cluster script failed'
  popd 2>&1
}

function execute_ansible_post() {
  ansible-playbook -i inventory atomic-master-post.yml
}

function fatal() {
  echo $1
  exit 1
}

main $@
