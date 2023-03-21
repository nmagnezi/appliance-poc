#!/bin/bash

# ISO 2 image for factory: agent.data.iso (not bootable)
# ======================================================
# Contains the following assets:
# - mirror_seq1_000000.tar (entire release payload)
# - images/registry.tar (to run a local registry)
# - custom service image
# - custom installer-agent image

source appliance_config.sh


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
}

log_info iso1_generator "iso2_generator start"
iso2_generator_main
log_info iso1_generator "iso2_generator end"