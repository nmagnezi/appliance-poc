#!/bin/bash

source appliance_config.sh

pushd "$POC_DIR"/appliance || exit 1

log_info install_monitor "To run cluster oc commands, ssh into the machine and: export KUBECONFIG=/etc/kubernetes/bootstrap-secrets/kubeconfig"

openshift-install agent wait-for install-complete
