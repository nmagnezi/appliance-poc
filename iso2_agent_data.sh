#!/bin/bash

# ISO 2 image for factory: agent.data.iso (not bootable)
# ======================================================
# Contains the following assets:
# - mirror_seq1_000000.tar (entire release payload)
# - images/registry.tar (to run a local registry)
# - custom service image
# - custom installer-agent image

source appliance_config.sh

# create cat imageset-config.yaml
read -r -d '' imageset-config << EOL
apiVersion: mirror.openshift.io/v1alpha2
kind: ImageSetConfiguration
mirror:
  platform:
    channels:
      - name: stable-4.12
        minVersion: 4.12.6
        maxVersion: 4.12.6
  additionalImages:
    - name: registry.redhat.io/ubi8/ubi:latest
EOL

function iso2_generator_main() {
  func_name=${FUNCNAME[0]}

  log_info "${func_name}" "Creating folder: $POC_DIR/assets/bin"
  mkdir -p "$POC_DIR"/assets/bin

  log_info "${func_name}" "Creating folder: $POC_DIR/assets/images"
  mkdir -p "$POC_DIR"/assets/images

  log_info "${func_name}" "Creating folder: $POC_DIR/assets/oc-mirror"
  mkdir -p "$POC_DIR"/assets/oc-mirror

  log_info "${func_name}" "Copy oc-mirror binary to $POC_DIR/assets/bin/"
  cp "$(which oc-mirror)" "$POC_DIR"/assets/bin/

  log_info "${func_name}" "Copy butane binary to $POC_DIR/assets/bin/"
  cp "$(which butane)" "$POC_DIR"/assets/bin

  log_info "${func_name}" "Copy (via skopeo) local registry: $REGISTRY_IMAGE to $POC_DIR/assets/images/registry.tar:registry:2"
  skopeo copy docker://"$REGISTRY_IMAGE" docker-archive:"$POC_DIR"/assets/images/registry.tar:registry:2
  log_info "${func_name}" "Copy (via skopeo) assisted-installer-agent: $ASSISTED_INSTALLER_AGENT_IMAGE to $POC_DIR/assets/images/ose-agent-installer-node-agent"
  skopeo copy --all docker://"$ASSISTED_INSTALLER_AGENT_IMAGE" dir:"$POC_DIR"/assets/images/ose-agent-installer-node-agent
  log_info "${func_name}" "Copy (via skopeo) assisted-service: $ASSISTED_INSTALLER_AGENT_IMAGE to $POC_DIR/assets/images/ose-agent-installer-api-server"
  skopeo copy --all docker://"$ASSISTED_SERVICE_IMAGE" dir:"$POC_DIR"/assets/images/ose-agent-installer-api-server

  log_info "${func_name}" "Generating imageset-config.yaml at $POC_DIR/assets/"
  echo "${imageset-config}" > "$POC_DIR"/assets/imageset-config.yaml
  pushd "$POC_DIR" || exit 1
  pushd assets/ || exit 1
  log_info "${func_name}" "Copy mirror_seq1_000000.tar  to oc-mirror directory"
  cp archives/mirror_seq1_000000.tar ./oc-mirror
  popd || exit 1
  log_info "${func_name}" "Run genisoimage on agent.data.iso"
  genisoimage -o agent.data.iso -allow-limited-size assets
  log_info "${func_name}" "Done generating $POC_DIR/agent.data.iso"
}

log_info iso1_generator "iso2_generator start"
iso2_generator_main
log_info iso1_generator "iso2_generator end"