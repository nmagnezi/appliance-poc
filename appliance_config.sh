#!/bin/bash

export POC_DIR=$HOME/appliance-poc-assets
export REGISTRY_IMAGE='quay.io/libpod/registry:2.8'
export ASSISTED_INSTALLER_AGENT_IMAGE='quay.io/masayag/assisted-installer-agent:billi'
export ASSISTED_SERVICE_IMAGE='quay.io/nmagnezi/assisted-service:appliance2'
export OCP_INSTALLER_REPO='https://github.com/danielerez/installer.git'
export OCP_INSTALLER_BRANCH='appliance'
export SSH_PUB_KEY=$(cat $HOME/.ssh/id_rsa.pub)
export PULL_SECRET=$(cat $HOME/pull-secret)

function log() {
  echo "$(date '+%F %T') $2[$$]: level=$1 msg=\"$3\""
}

function log_info() {
  log "info" "$1" "$2"
}

function log_error() {
  log "error" "$1" "$2"
}
