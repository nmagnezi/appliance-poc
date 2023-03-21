#!/bin/bash

export POC_DIR='/root/appliance-poc-assets'

function log() {
  echo "$(date '+%F %T') $2[$$]: level=$1 msg=\"$3\""
}

function log_info() {
  log "info" "$1" "$2"
}

function log_error() {
  log "error" "$1" "$2"
}
