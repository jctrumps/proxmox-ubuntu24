# Create Proxmox Ubuntu 24.04 LTS Template

## Purpose

Create a reusable Ubuntu Server 24.04 LTS cloud-init template in Proxmox VE for clone-based provisioning.

## Why This Method

This project uses the Ubuntu cloud image, not the live server ISO, because the cloud image aligns with:

- repeatable template creation
- cloud-init driven configuration
- clone-based provisioning from OpenToFu

## Recommended Image

Download the Ubuntu 24.04 LTS cloud image:

- `noble-server-cloudimg-amd64.img`

Official source:

- `https://cloud-images.ubuntu.com/noble/current/`

## Proven Storage Guidance

- Use `local-lvm` for the template disk and cloud-init disk
- Do not rely on NFS for the template conversion step unless you have confirmed the backend supports the required Proxmox file operations
- Prefer downloading the original Ubuntu cloud image directly on the Proxmox node for the first template build instead of relying on a storage-converted `.img.raw` copy

In this project, template conversion on NFS failed because the underlying storage did not support the `chattr` operation Proxmox attempted during template conversion.

In this project, the most reliable import path was to download the original `.img` file on the Proxmox node and import from that local path.

## UI Preparation

Create an empty VM shell in the Proxmox UI.

Recommended settings:

- VM ID: `9000`
- Name: `ubuntu-2404-cloud-template`
- SCSI controller: `VirtIO SCSI`
- Network model: `VirtIO`
- Bridge: your target bridge such as `vmbr0`
- CPU cores: `2`
- Memory: `2048` or `4096`

If the UI creates placeholder media, remove:

- the temporary hard disk
- the temporary CD/DVD drive

Keep:

- CPU and memory settings
- network interface
- `VirtIO SCSI` controller

## Import The Cloud Image

Use the Proxmox node shell.

Proven command sequence:

```bash
qm destroy 9000 --purge
cd /root
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
qm create 9000 --name ubuntu-2404-cloud-template --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci --bios ovmf --machine q35
qm set 9000 --scsi0 local-lvm:0,import-from=./noble-server-cloudimg-amd64.img
qm resize 9000 scsi0 30G
qm set 9000 --efidisk0 local-lvm:0,pre-enrolled-keys=0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot order=scsi0
qm set 9000 --ciuser ubuntu
qm start 9000
```

## UEFI Boot Guidance

The Ubuntu cloud image is UEFI-oriented. Before using the VM as a template, make sure the VM boots successfully with these settings:

- BIOS: `OVMF (UEFI)`
- Machine: `q35`
- an EFI disk present on `local-lvm`
- boot order set to `scsi0`

Do not assume a cloned VM will fix a broken template boot path. Validate the template itself first.

## Display And Console Guidance

The serial console did not provide useful guest boot output in this environment.

Proven behavior:

- `serial0` can connect successfully without showing a normal Ubuntu boot sequence
- changing `Display` to `Default` in the Proxmox UI made boot validation easier

Recommended validation approach:

1. Set `Display` to `Default` while validating the first template boot
2. Use `noVNC` or the standard console view to confirm Ubuntu actually boots
3. Add `serial0` later only if you want it for troubleshooting

If the guest falls into the UEFI shell, PXE, or `no boot device`, treat that as a template import or boot-layout problem first.

Optional SSH key injection on the template definition:

```bash
qm set 9000 --sshkey /root/.ssh/id_ed25519.pub
```

Optional serial console configuration for later troubleshooting:

```bash
qm set 9000 --serial0 socket --vga serial0
```

## Convert To Template

Stop the VM if needed, then convert it to a template.

Before conversion, boot-test the VM once and confirm the guest is actually bootable.

After validation:

```bash
qm shutdown 9000
qm template 9000
```

In the UI:

1. Select the VM
2. Ensure it is stopped
3. Right-click the VM
4. Choose `Convert to template`

Shell alternative:

```bash
qm template 9000
```

## Validation

Confirm the template state:

```bash
qm config 9000
```

The config should include:

- `template: 1`
- `scsi0` on `local-lvm`
- `ide2` cloud-init drive
- `ciuser: ubuntu`

A successful manual boot test here proves template bootability only. It does not by itself prove that the OpenToFu provider will complete resource creation and write state during clone-based provisioning.

## Notes

- Reserve the `9000` range for templates if possible
- Use a different VM ID for actual cloned VMs, such as `2100`
- Record the template VM ID for `template_vm_id` in `terraform.tfvars`
- If a clone reports `no boot device`, rebuild or correct the template first instead of patching clones one by one
- If a storage-imported `.img.raw` file behaves inconsistently, prefer the original Ubuntu `.img` downloaded directly to the Proxmox node
