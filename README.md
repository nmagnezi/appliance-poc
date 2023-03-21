End result:
```shell
[root@nmagnezi appliance-poc-assets]# tree -L 3
.
├── appliance
│   ├── agent.x86_64.iso
│   ├── auth
│   │   ├── kubeadmin-password
│   │   └── kubeconfig
│   ├── extracted
│   │   ├── [BOOT]
│   │   ├── config.ign
│   │   ├── coreos
│   │   ├── EFI
│   │   ├── images
│   │   ├── isolinux
│   │   └── zipl.prm
│   └── rendezvousIP
├── appliance_config.sh
├── assets
│   ├── bin
│   │   ├── butane
│   │   └── oc-mirror
│   ├── images
│   │   ├── ose-agent-installer-api-server
│   │   ├── ose-agent-installer-node-agent
│   │   └── registry.tar
│   ├── imageset-config.yaml
│   └── oc-mirror
├── config
│   ├── build_iso.sh
│   ├── config.ign
│   ├── create_ign.sh
│   ├── issue_status.sh
│   └── setup.sh
├── installer
│   <trimmed>
└── iso
    ├── agent.config.iso
    ├── agent.custom.iso
    └── agent.data.iso

```