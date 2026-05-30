# Changelog

## 0.1.0 - 2026-05-24

- Initial template project scaffold.
- Uses direct local image download and `qm set ... import-from=...`.
- Adds guest-side `qemu-guest-agent` install and `cloud-init clean` step before template conversion.
- Documents Proxmox automation users, roles, ACLs, and future API-token use.
- Clarifies the working image download path and `scsi0` boot-disk requirement.
- Updates guest prep to use a runtime guest-agent check, `cloud-init clean --machine-id`, and SSH host key cleanup.
- Adds an SSH cheat sheet for Windows, Proxmox host access, and VM key injection.
- Records successful downstream consumption of the finished Proxmox template.
- Changes template creation to `virtio-scsi-single` with `iothread=1` on `scsi0`.
- Adds a default `local-lvm` storage safety guard with explicit `ALLOW_UNSAFE_STORAGE=true` opt-in for other backends.
- Removes hardcoded node and storage defaults from Proxmox automation access setup.
- Renames the template from `ubuntu-2404-cloud-template` to `ubuntu-2404-cloudinit` before downstream adoption.
- Confirms the updated `ubuntu-2404-cloudinit` template was validated successfully.
- Reduces the default template disk size to `10G` for smaller local storage environments.
