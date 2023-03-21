#!/bin/bash

# ISO 3 image for factory: agent.custom.iso (bootable)
# ======================================================
# The agent ISO that supports disconnected flow
# Runs a local registry using ‘agentdata’ partition (created by agent.config.iso)
# Start installation on /dev/sda

source appliance_config.sh


# create cat agent-config.yaml
read -r -d '' agent_config << EOL
apiVersion: v1alpha1
metadata:
  name: appliance
rendezvousIP: 192.168.122.116
hosts:
  - hostname: sno
    installerArgs: '["--save-partlabel", "agent*", "--save-partlabel", "rhcos-*"]'
    interfaces:
     - name: enp1s0
       macAddress: 52:54:00:51:a8:2b
    networkConfig:
      interfaces:
        - name: enp1s0
          type: ethernet
          state: up
          mac-address: 52:54:00:51:a8:2b
          ipv4:
            enabled: true
            dhcp: true
EOL

# create cat install-config.yaml
read -r -d '' install_config << EOL
apiVersion: v1
baseDomain: appliance.com
imageContentSources:
  - source: quay.io/openshift-release-dev/ocp-release
    mirrors:
      - registry.appliance.com/openshift/release-images
  - source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
    mirrors:
      - registry.appliance.com/openshift/release
  - source: quay.io
    mirrors:
      - registry.appliance.com
  - source: registry.redhat.io/ubi8
    mirrors:
      - registry.appliance.com/ubi8
  - source: registry.ci.openshift.org/ocp/release
    mirrors:
      - registry.appliance.com/openshift/release-images
compute:
- architecture: amd64
  hyperthreading: Enabled
  name: worker
  replicas: 0
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  replicas: 1
metadata:
  name: appliance
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 192.168.122.0/24
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.30.0.0/16
platform:
  none: {}
pullSecret: '$PULL_SECRET'
sshKey: '$SSH_PUB_KEY'
EOL

function iso3_generator_main() {
  func_name=${FUNCNAME[0]}
  pushd "$POC_DIR" || exit 1
  log_info "${func_name}" "Cloning ocp installer branch '$OCP_INSTALLER_BRANCH'from $OCP_INSTALLER_REPO"
  git clone --branch "$OCP_INSTALLER_BRANCH" "$OCP_INSTALLER_REPO"
  pushd installer || exit 1

  log_info "${func_name}" "Running: hack/build.sh"
  ./hack/build.sh
  log_info "${func_name}" "Running: patch_release_version.sh"
  ./patch_release_version.sh
  log_info "${func_name}" "Copying the modified openshift-install binary to /usr/local/bin"
  /usr/bin/cp -f bin/openshift-install /usr/local/bin/
  popd || exit 1
  mkdir "$POC_DIR"/appliance
  pushd appliance || exit 1

  log_info "${func_name}" "Generating agent-config.yaml at $POC_DIR/appliance/"
  echo "${agent_config}" > "$POC_DIR"/appliance/agent-config.yaml

  log_info "${func_name}" "Generating install-config.yaml at $POC_DIR/appliance/"
  echo "${install_config}" > "$POC_DIR"/appliance/install-config.yaml
}

log_info iso1_generator "iso3_generator start"
iso3_generator_main
log_info iso1_generator "iso3_generator end"
