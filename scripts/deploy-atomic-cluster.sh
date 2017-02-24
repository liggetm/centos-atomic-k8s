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
      h ) showUsage
          exit 1;;
      d ) enable_insecure=true;;
      * ) showUsage
          exit 1;;
    esac
  done

  check_deps

  export LC_ALL="en_US.UTF-8" #Used to ensure no setlocale mapping errors

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
  log "Checking dependencies..."
  if [ ! -f "${INVENTORY_FILE}" ]; then
    fatal "inventory file not found in current directory"
  fi

  which -s ansible-playbook || fatal "ansible-playbook not found on path"

  if [ ! -f "${KUBERNETES_SCRIPT_DIR}/${KUBERNETES_SCRIPT}" ]; then
    fatal "Kubernetes contrib project not found in third-party directory"
  fi

  if [ ! -d "${KUBERNETES_INVENTORY_DIR}" ]; then
    fatal "inventory directory not found for Kubernetes contrib project"
  fi
  log_success "Checking dependencies"
}

function execute_ansible_pre() {
  log "Executing Atomic host playbook..."
  ansible-playbook -i inventory atomic-master-pre.yml || fatal "Failed to complete pre Kubernetes playbook"
  log_success "Executing Atomic host playbook"
}

function execute_k8s_deploy_cluster() {
  log "Executing Kubernetes deploy-cluster script..."
  /bin/cp -f ${INVENTORY_FILE} ${KUBERNETES_INVENTORY_DIR} || fatal "Failed to copy inventory file to third-party directory"
  pushd ${KUBERNETES_SCRIPT_DIR} 2>&1
  ./${KUBERNETES_SCRIPT} || fatal "Kubernetes deploy-cluster script failed"
  popd 2>&1
  log_success "Executing Kubernetes deploy-cluster script"
}

function execute_ansible_post() {
  log "Installing Atomic host playbook..."
  ansible-playbook -i inventory atomic-master-post.yml || fatal "Failed to complete post Kubernetes playbook"
  log_success "Installing Atomic host playbook"
}

function fatal() {
  log_failure
  log "\nERROR: $1\n"
  exit 1
}

function log() {
  printf "$1"
}

function log_success() {
  log "$1:\t[SUCCESS]\n"
}

function log_failure() {
  log "$1:\t[FAILED]\n"
}

main $*
