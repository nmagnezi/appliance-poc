#!/bin/bash

export POC_DIR=${POC_DIR:-$HOME/appliance-poc-assets}

export REGISTRY_IMAGE=${REGISTRY_IMAGE:-'quay.io/libpod/registry:2.8'}
export ASSISTED_INSTALLER_AGENT_IMAGE=${ASSISTED_INSTALLER_AGENT_IMAGE:-'quay.io/masayag/assisted-installer-agent@sha256:93afd3965abb3b1019d001a096280e4f012843f734e6d5851f0bac743f4ffaa3'}
export ASSISTED_SERVICE_IMAGE=${ASSISTED_SERVICE_IMAGE:-'quay.io/nmagnezi/assisted-service@sha256:d8190195889efb5333eeec18af9b6c82313edd4db62989bd3a357caca4f13f0e'}

export OCP_INSTALLER_REPO=${OCP_INSTALLER_REPO:-'https://github.com/danielerez/installer.git'}
export OCP_INSTALLER_BRANCH=${OCP_INSTALLER_BRANCH:-'appliance'}

export SSH_PUB_KEY=$(cat $HOME/.ssh/id_rsa.pub)
export PULL_SECRET=$(cat $HOME/pull-secret)

export SKIP_OC_MIRROR=${SKIP_OC_MIRROR:-false}

export CHANNEL_NAME=${CHANNEL_NAME:-'candidate-4.12'}
export CHANNEL_MIN_VERSION=${CHANNEL_MIN_VERSION:-'4.12.8'}
export CHANNEL_MAX_VERSION=${CHANNEL_MAX_VERSION:-'4.12.8'}

function log() {
  echo "$(date '+%F %T') $2[$$]: level=$1 msg=\"$3\""
}

function log_info() {
  log "info" "$1" "$2"
}

function log_error() {
  log "error" "$1" "$2"
}
