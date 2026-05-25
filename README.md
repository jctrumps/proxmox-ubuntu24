# proxmox-ubuntu24

Create a reusable Ubuntu Server 24.04 LTS cloud-init template for Proxmox VE.

This repository stays focused on template creation only. Future OpenTofu and Ansible projects can consume the completed template.

## Defaults

| Setting | Value |
|---|---|
| VMID | `9024` |
| Template name | `ubuntu-2404-cloudinit` |
| Image | `noble-server-cloudimg-amd64.img` |
| Storage | `local-lvm` by default |
| Bridge | `vmbr0` |
| Cloud-init user | `ubuntu` |

This workflow defaults to `local-lvm` for template creation. Other storage backends require `ALLOW_UNSAFE_STORAGE=true` because template conversion already failed on NFS-backed storage in this repo.

## Quick Start

```bash
cp config/template.env.example config/template.env
nano config/template.env

./scripts/check-host.sh
./scripts/create-template.sh
```

The VM will start for first-boot validation. Inside the VM, install the guest agent and clean cloud-init:

```bash
sudo apt update
sudo apt install -y qemu-guest-agent
sudo systemctl start qemu-guest-agent
systemctl is-active qemu-guest-agent
sudo cloud-init clean --logs --machine-id
sudo rm -f /etc/ssh/ssh_host_*
sudo shutdown now
```

Then convert it:

```bash
./scripts/convert-to-template.sh
```

The imported boot disk uses `VirtIO SCSI Single` with `iothread=1`.
