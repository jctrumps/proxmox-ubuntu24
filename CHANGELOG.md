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
