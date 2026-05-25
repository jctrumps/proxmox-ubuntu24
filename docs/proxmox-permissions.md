# Proxmox Automation Users and Roles

This project creates cloud templates only, but future OpenTofu and Ansible projects need a predictable Proxmox permission model.

## Users

| User | Purpose |
|---|---|
| `automation@pve` | Provisioning user for future OpenTofu and Ansible |
| `workbench@pve` | Read-only audit/discovery user |

## Roles

### `DevOpsProvisioner`

Privileges:

```text
Datastore.AllocateSpace Datastore.Audit Pool.Allocate SDN.Use Sys.Audit VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.GuestAgent.Audit VM.Migrate VM.PowerMgmt
```

### `PVEAuditor`

Privileges:

```text
Datastore.Audit Mapping.Audit Pool.Audit SDN.Audit Sys.Audit VM.Audit VM.GuestAgent.Audit
```

## ACL Inventory

| Path | User / Token | Role |
|---|---|---|
| `/` | `workbench@pve` | `PVEAuditor` |
| `/nodes` | `automation@pve` | `DevOpsProvisioner` |
| `/sdn/zones` | `automation@pve` | `DevOpsProvisioner` |
| `/storage` | `automation@pve` | `DevOpsProvisioner` |
| `/vms` | `automation@pve` | `DevOpsProvisioner` |

Optional node/storage-specific ACLs should only be added when you explicitly set the matching variables before running `scripts/setup-proxmox-automation-access.sh`:

- `NODE_NAME`
- `LOCAL_STORAGE_NAME`
- `TEMPLATE_STORAGE_NAME`
- `EXTRA_STORAGE_NAME`

## Optional Shell Setup

Review and set optional node/storage variables before running. Leave a variable unset to skip that node- or storage-specific ACL:

```bash
NODE_NAME="pve-node-name" \
LOCAL_STORAGE_NAME="local" \
TEMPLATE_STORAGE_NAME="local-lvm" \
EXTRA_STORAGE_NAME="shared-storage" \
./scripts/setup-proxmox-automation-access.sh
```

## API Tokens

Create tokens later when the future OpenTofu/Ansible projects are ready:

```bash
pveum user token add automation@pve opentofu --comment "OpenTofu provisioning token"
pveum user token add automation@pve ansible --comment "Ansible automation token"
pveum user token add workbench@pve inventory --comment "Read-only inventory token"
```

Do not commit token secrets.
