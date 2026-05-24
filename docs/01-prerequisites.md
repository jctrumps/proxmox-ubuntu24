# Prerequisites

Run this project on the Proxmox node as `root`.

Required:

- available VMID `9024`
- storage `local-lvm`
- bridge `vmbr0`
- working internet access from the Proxmox node
- commands: `qm`, `pvesm`, `wget`, `ip`

Check:

```bash
qm status 9024
pvesm status
ip link show vmbr0
```
