# Proxmox Cloud Template Inventory

Starting inventory for Debian and Ubuntu cloud-init templates.

```text
# Debian / Ubuntu cloud templates
9012 - Debian 12        # legacy if needed
9013 - Debian 13
9024 - Ubuntu 24.04 LTS # ubuntu-2404-cloudinit
9026 - Ubuntu 26.04 LTS # future/reserved
```

## Rules

- Keep template VMIDs separate from cloned workload VMIDs.
- Future OpenTofu and Ansible projects should treat these VMIDs as stable contracts.
- Rebuild a template in-place only when you intend to preserve its ID and downstream compatibility.
