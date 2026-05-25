# AGENTS.md

## Purpose

This repository builds and validates a reusable Proxmox Ubuntu 24.04 cloud-init template.

Keep changes focused on template creation, guest preparation, validation, and documentation for that workflow.

## Current Defaults

- Template VMID: `9024`
- Template name: `ubuntu-2404-cloudinit`
- Test VMID: `2100`
- Default template-build storage: `local-lvm`
- Cloud-init user: `ubuntu`

## Required Workflow Rules

1. Keep scripts, docs, and examples aligned.
2. Default to `local-lvm` for template creation.
3. Do not allow other storage backends unless `ALLOW_UNSAFE_STORAGE=true` is explicitly set.
4. Use `virtio-scsi-single` for the SCSI controller.
5. Import the boot disk as `scsi0` with `iothread=1`.
6. Prefer downloading the Ubuntu cloud image directly on the Proxmox node into `/root/proxmox-cloud-images`.
7. Validate first boot before converting the VM to a template.

## Canonical Guest Prep

Use this exact sequence unless a proven replacement is documented everywhere it appears:

```bash
sudo apt update
sudo apt install -y qemu-guest-agent
sudo systemctl start qemu-guest-agent
systemctl is-active qemu-guest-agent
sudo cloud-init clean --logs --machine-id
sudo rm -f /etc/ssh/ssh_host_*
sudo shutdown now
```

Notes:

- On this Ubuntu 24.04 image, `qemu-guest-agent.service` is static, so do not switch docs or examples back to `systemctl enable`.
- Preserve the host key cleanup and `--machine-id` reset before template conversion.

## Automation Access Script Rules

When editing `scripts/setup-proxmox-automation-access.sh` or related docs:

- do not hardcode node names or extra storage names
- only add node-specific or storage-specific ACLs when the matching variables are explicitly set
- keep examples environment-neutral

## Documentation Rules

- Keep the active workflow on VMID `9024` and template name `ubuntu-2404-cloudinit`.
- Historical notes may mention `9000`, but active instructions should match the current repo defaults.
- If template creation hardware changes, update all duplicated command blocks and validation expectations.
- If guest prep changes, update `README.md`, `guest/prepare-guest.sh`, `docs/04-guest-prep.md`, `docs/security.md`, and any duplicated examples.

## Validation Expectations

After conversion, expected config includes:

- `template: 1`
- `scsihw: virtio-scsi-single`
- `scsi0` on `local-lvm`
- `scsi0` with `iothread=1`
- `ide2` cloud-init drive
- `ciuser: ubuntu`
- `agent: enabled=1`
- `bios: ovmf`
- `machine: q35`
