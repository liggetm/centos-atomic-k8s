#!/bin/bash

SCRIPT=$0
SCRIPT_NAME=$(basename $SCRIPT)
INVENTORY_FILE="./inventory"
KUBERNETES_SCRIPT_DIR="./third-party/contrib/ansible/scripts"
KUBERNETES_SCRIPT="deploy-cluster.sh"
KUBERNETES_INVENTORY_DIR="./third-party/contrib/ansible/inventory"
LOG_FILE="./logs/deploy-atomic-cluster.log"

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

  log_header
  check_deps

  export LC_ALL="en_US.UTF-8" #Used to ensure no setlocale mapping errors

  execute_ansible_pre
  execute_k8s_deploy_cluster

  if [ "${enable_insecure}" = "true" ]; then
    execute_ansible_post
  fi

  echo_kubectl_context

  log_footer
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

  which -s kubectl || warning "Kubectl not found on the local path!"

  log_success

}

function execute_ansible_pre() {
  log "Executing Atomic host pre playbook..."
  ansible-playbook -i inventory atomic-master-pre.yml >> "${LOG_FILE}" 2>&1 || fatal "Failed to complete pre Kubernetes playbook"
  log_success
}

function execute_k8s_deploy_cluster() {
  log "Executing Kubernetes deploy-cluster script..."
  /bin/cp -f ${INVENTORY_FILE} ${KUBERNETES_INVENTORY_DIR} || fatal "Failed to copy inventory file to third-party directory"
  pushd ${KUBERNETES_SCRIPT_DIR} >> "${LOG_FILE}" 2>&1
  ./${KUBERNETES_SCRIPT} >> "${LOG_FILE}" 2>&1 || fatal "Kubernetes deploy-cluster script failed"
  popd 2>&1 >> "${LOG_FILE}"
  log_success
}

function execute_ansible_post() {
  log "Installing Atomic host post playbook..."
  ansible-playbook -i inventory atomic-master-post.yml >> "${LOG_FILE}" 2>&1 || fatal "Failed to complete post Kubernetes playbook"
  log_success
}

function echo_kubectl_context() {
  master_line=$(sed -n 2p ${INVENTORY_FILE})
  master=$(echo ${master_line} | awk '{print $1}')
  user=$(echo ${master_line} | awk -F= '{print $NF}')
  if $(echo ${master} | grep -q ":"); then
    port=$(echo ${master} | awk -F: '{print $NF}')
    ssh -p ${port} ${user}@${master} "echo "[START]";cat /etc/kubernetes/kubectl.kubeconfig; echo "[END]""
  else
    ssh ${user}@${master} "echo "";cat /etc/kubernetes/kubectl.kubeconfig; echo """
  fi
}

### LOGGING FUNCTIONS ###
function log_header() {
  log_line
  log_to_file "* ${SCRIPT_NAME} @ $(date "+%Y/%m/%d %H:%M:%S")\n"
  log_line
}

function log_footer() {
  log_to_file "\n"
  log_line
}

function log_line() {
  log_to_file "******************************************************************\n"
}

function fatal() {
  log_failure
  log "\nERROR: $1\n"
  exit 1
}

function warning() {
  log "\nWARNING: $1\n"
}

function log() {
  printf "$1"
  log_to_file "$1"
}

function log_to_file() {
  printf "$1" >> "${LOG_FILE}"
}

function log_success() {
  log "\t[SUCCESS]\n"
  log_to_file "$1"
}

function log_failure() {
  log "\t[FAILED]\n"
  log_to_file "$1"
}

main $*
