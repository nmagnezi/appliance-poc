#!/bin/bash

# ISO 1 image for factory: agent.config.iso (bootable)
# ====================================================
# Image is based on coreos-x86_64.iso
# Creates ‘agentdata’ partition on /dev/sdb (via ignition)
# Runs a local registry
# Pushes oc-mirror to the local registry
# Pushes custom images to the local registry: service/installer-agent
# Copies agent ISO to /dev/sdc


source appliance_config.sh

# create build_iso.sh
read -r -d '' build_iso << EOL
#!/usr/bin/env bash

source ../appliance_config.sh

./create_ign.sh

rm -rf $POC_DIR/agent.config.iso

coreos-installer iso customize \
  --live-ignition config.ign \
  -o $POC_DIR/iso/agent.config.iso \
  ~/.cache/agent/image_cache/coreos-x86_64.iso

log_info "build_iso.sh" "Done generating $POC_DIR/iso/agent.config.iso"
EOL



# create create_ign.sh
read -r -d '' create_ign << EOL
#!/usr/bin/env bash

source ../appliance_config.sh

butane --pretty --strict --files-dir .  << EOF > config.ign
variant: fcos
version: 1.4.0
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - "$SSH_PUB_KEY"
systemd:
  units:
    - name: setup.service
      enabled: true
      contents: |
        [Unit]
        Before=setup.service
        Wants=network-online.target
        After=network-online.target

        [Service]
        Type=oneshot
        ExecStart=/usr/local/bin/setup.sh
        RemainAfterExit=yes

        [Install]
        WantedBy=multi-user.target
storage:
  files:
    - path: /usr/local/bin/setup.sh
      mode: 0755
      contents:
        local: setup.sh
    - path: /usr/local/bin/issue_status.sh
      mode: 0755
      contents:
        local: issue_status.sh
  disks:
    - device: /dev/sdb
      partitions:
        - number: 1
          size_mib: 40000
          label: agentdata
      wipe_table: true
  filesystems:
    - device: /dev/disk/by-partlabel/agentdata
      format: ext4
      label: agentdata
      wipe_filesystem: true
EOF
EOL


# create issue_status.sh
read -i text -d '' issue_status << EOL
#!/bin/bash

issue_file() {
    printf "/etc/issue.d/%s.issue" "\$1"
}

set_issue() {
    local outfile
    outfile="\$(issue_file "\$1")"
    local tmp
    tmp="\$(mktemp)"
    {
        printf '\\\n'
        cat -
        printf '\\\n'
    } >"\${tmp}"
    if ! diff "\${tmp}" "\${outfile}" >/dev/null 2>&1; then
        mv "\${tmp}" "\${outfile}"
        agetty --reload
    else
        rm "\${tmp}"
    fi
}

clear_issue() {
    local outfile
    outfile="\$(issue_file "\$1")"
    if [ -f "\${outfile}" ]; then
        rm "\${outfile}"
        agetty --reload
    fi
}
EOL

# create setup.sh
read -i text -d '' setup << EOL
#!/bin/bash

source issue_status.sh

status_issue="00_setup"

# Mount assets ISO
mkdir /mnt/sr1
mount -t auto /dev/sr1 /mnt/sr1

# Mount agent ISO
mkdir /mnt/sr2
mount -t auto /dev/sr2 /mnt/sr2

# Load registry image
podman load -q -i /mnt/sr1/images/registry.tar

# Run local registry image
mkdir -p /mnt/agentdata
mount -t auto /dev/disk/by-partlabel/agentdata /mnt/agentdata
mkdir -p /mnt/agentdata/registry
podman run --privileged -d --name registry -p 5000:5000 -v /mnt/agentdata/registry:/var/lib/registry --restart=always docker.io/library/registry:2

# Copy images to sda (so the Agent ISO could load registry.tar)
cp -r /mnt/sr1/images /mnt/agentdata/

# Push AI images to registry (just for testing, latest images should be in the release payload)
skopeo copy dir:/mnt/sr1/images/ose-agent-installer-node-agent docker://0.0.0.0:5000/masayag/assisted-installer-agent:billi --dest-tls-verify=false
skopeo copy dir:/mnt/sr1/images/ose-agent-installer-api-server docker://0.0.0.0:5000/nmagnezi/assisted-service:appliance2 --dest-tls-verify=false

printf '\\\\\\\e{yellow}Pushing OC mirror to a local registry...\\\n\\\\\\\e{reset}' | set_issue "\${status_issue}"
cp /mnt/sr1/bin/oc-mirror /usr/local/bin/
cd /usr/local/bin/
chmod +x oc-mirror
./oc-mirror --from /mnt/sr1/oc-mirror/mirror_seq1_000000.tar docker://0.0.0.0:5000 --dest-use-http

printf '\\\\\\\e{yellow}Copying Agent ISO to /dev/sdc...\\\n\\\\\\\e{reset}' | set_issue "\${status_issue}"
dd if=/dev/sr2 of=/dev/sdc status=progress conv="fsync"

printf '\\\\\\\e{lightgreen}Done! Please reboot system from /dev/sdc\\\n\\\\\\\e{reset}' | set_issue "\${status_issue}"
EOL

function iso1_generator_main() {
  func_name=${FUNCNAME[0]}
  appliance_config=$(cat appliance_config.sh)

  mkdir -p "$POC_DIR"/config
  mkdir -p "$POC_DIR"/iso
  pushd "$POC_DIR"/config || exit 1

  log_info "${func_name}" "Generating appliance_config.sh in $POC_DIR"
  echo "${appliance_config}" > "$POC_DIR"/appliance_config.sh

  log_info "${func_name}" "Generating build_iso.sh at $POC_DIR/config/"
  echo "${build_iso}" > "$POC_DIR"/config/build_iso.sh

  log_info "${func_name}" "Generating create_ign.sh at $POC_DIR/config/"
  echo "${create_ign}" > "$POC_DIR"/config/create_ign.sh

  log_info "${func_name}" "Generating issue_status.sh at $POC_DIR/config/"
  echo "${issue_status}" > "$POC_DIR"/config/issue_status.sh

  log_info "${func_name}" "Generating setup.sh at $POC_DIR/config/"
  echo "${setup}" > "$POC_DIR"/config/setup.sh

  chmod +x build_iso.sh create_ign.sh issue_status.sh setup.sh
  ./build_iso.sh
}

log_info iso1_generator "iso1_generator start"
iso1_generator_main
log_info iso1_generator "iso1_generator end"
