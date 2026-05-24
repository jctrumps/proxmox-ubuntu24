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
| `/nodes/pve-minibox-01` | `automation@pve` | `DevOpsProvisioner` |
| `/sdn/zones` | `automation@pve` | `DevOpsProvisioner` |
| `/storage` | `automation@pve` | `DevOpsProvisioner` |
| `/storage/local` | `automation@pve` | `DevOpsProvisioner` |
| `/storage/local-lvm` | `automation@pve` | `DevOpsProvisioner` |
| `/storage/mycloudpr2100` | `automation@pve` | `DevOpsProvisioner` |
| `/vms` | `automation@pve` | `DevOpsProvisioner` |

## Optional Shell Setup

Review and adjust node/storage names before running:

```bash
pveum user add automation@pve --comment "Automation user for OpenTofu and Ansible"
pveum user add workbench@pve --comment "Read-only workbench/audit user"

pveum role add DevOpsProvisioner -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate SDN.Use Sys.Audit VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.GuestAgent.Audit VM.Migrate VM.PowerMgmt"
pveum role add PVEAuditor -privs "Datastore.Audit Mapping.Audit Pool.Audit SDN.Audit Sys.Audit VM.Audit VM.GuestAgent.Audit"

pveum acl modify / -user workbench@pve -role PVEAuditor
pveum acl modify /nodes -user automation@pve -role DevOpsProvisioner
pveum acl modify /nodes/pve-minibox-01 -user automation@pve -role DevOpsProvisioner
pveum acl modify /sdn/zones -user automation@pve -role DevOpsProvisioner
pveum acl modify /storage -user automation@pve -role DevOpsProvisioner
pveum acl modify /storage/local -user automation@pve -role DevOpsProvisioner
pveum acl modify /storage/local-lvm -user automation@pve -role DevOpsProvisioner
pveum acl modify /storage/mycloudpr2100 -user automation@pve -role DevOpsProvisioner
pveum acl modify /vms -user automation@pve -role DevOpsProvisioner
```

## API Tokens

Create tokens later when the future OpenTofu/Ansible projects are ready:

```bash
pveum user token add automation@pve opentofu --comment "OpenTofu provisioning token"
pveum user token add automation@pve ansible --comment "Ansible automation token"
pveum user token add workbench@pve inventory --comment "Read-only inventory token"
```

Do not commit token secrets.
