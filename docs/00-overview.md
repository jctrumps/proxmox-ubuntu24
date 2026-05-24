# Overview

This project creates a reusable Ubuntu Server 24.04 LTS cloud-init template in Proxmox VE.

It uses the Ubuntu cloud image, not the live server ISO, because the cloud image supports repeatable cloud-init based provisioning and clone workflows.

The historical build used VMID `9000`; this project uses VMID `9024` to match the current inventory.

## Build Flow

1. Download the original Ubuntu cloud image directly on the Proxmox node.
2. Create a VM shell with OVMF/UEFI and q35.
3. Import the image into `local-lvm` with `qm set --scsi0 ... import-from=...`.
4. Boot-test the VM.
5. Install and verify `qemu-guest-agent`.
6. Clean cloud-init, reset `machine-id`, and remove guest SSH host keys.
7. Shut down and convert to template.
