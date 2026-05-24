# Troubleshooting

## Download Failed

Manually run:

```bash
mkdir -p /root/proxmox-cloud-images
cd /root/proxmox-cloud-images
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
```

Then rerun `./scripts/create-template.sh`.

## NFS Conversion Failure

The earlier build failed when template conversion used NFS-backed storage because Proxmox attempted an unsupported `chattr` operation.

Use `local-lvm` for the initial template build unless you have confirmed your storage backend supports Proxmox's template conversion operations.

## UEFI Shell / PXE / No Boot Device

Confirm:

- `bios: ovmf`
- `machine: q35`
- `efidisk0` exists
- `scsi0` exists
- boot order is `scsi0`

## Serial Console Is Blank

Use the default Proxmox display/noVNC for first validation. Add serial console later only if needed.
