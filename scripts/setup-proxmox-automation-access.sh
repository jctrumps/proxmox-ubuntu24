#!/usr/bin/env bash
set -Eeuo pipefail

NODE_NAME="${NODE_NAME:-}"
LOCAL_STORAGE_NAME="${LOCAL_STORAGE_NAME:-}"
TEMPLATE_STORAGE_NAME="${TEMPLATE_STORAGE_NAME:-}"
EXTRA_STORAGE_NAME="${EXTRA_STORAGE_NAME:-}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this on the Proxmox node as root."
  exit 1
fi

if ! command -v pveum >/dev/null 2>&1; then
  echo "pveum not found. Run this on a Proxmox node."
  exit 1
fi

DEVOPS_PRIVS="Datastore.AllocateSpace Datastore.Audit Pool.Allocate SDN.Use Sys.Audit VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.GuestAgent.Audit VM.Migrate VM.PowerMgmt"
AUDITOR_PRIVS="Datastore.Audit Mapping.Audit Pool.Audit SDN.Audit Sys.Audit VM.Audit VM.GuestAgent.Audit"

pveum user add automation@pve --comment "Automation user for OpenTofu and Ansible" 2>/dev/null || true
pveum user add workbench@pve --comment "Read-only workbench/audit user" 2>/dev/null || true

pveum role add DevOpsProvisioner -privs "${DEVOPS_PRIVS}" 2>/dev/null || pveum role modify DevOpsProvisioner -privs "${DEVOPS_PRIVS}"
pveum role add PVEAuditor -privs "${AUDITOR_PRIVS}" 2>/dev/null || pveum role modify PVEAuditor -privs "${AUDITOR_PRIVS}"

pveum acl modify / -user workbench@pve -role PVEAuditor

pveum acl modify /nodes -user automation@pve -role DevOpsProvisioner
pveum acl modify /sdn/zones -user automation@pve -role DevOpsProvisioner
pveum acl modify /storage -user automation@pve -role DevOpsProvisioner
pveum acl modify /vms -user automation@pve -role DevOpsProvisioner

if [[ -n "${NODE_NAME}" ]]; then
  pveum acl modify "/nodes/${NODE_NAME}" -user automation@pve -role DevOpsProvisioner
fi

if [[ -n "${LOCAL_STORAGE_NAME}" ]]; then
  pveum acl modify "/storage/${LOCAL_STORAGE_NAME}" -user automation@pve -role DevOpsProvisioner
fi

if [[ -n "${TEMPLATE_STORAGE_NAME}" ]]; then
  pveum acl modify "/storage/${TEMPLATE_STORAGE_NAME}" -user automation@pve -role DevOpsProvisioner
fi

if [[ -n "${EXTRA_STORAGE_NAME}" ]]; then
  pveum acl modify "/storage/${EXTRA_STORAGE_NAME}" -user automation@pve -role DevOpsProvisioner
fi

echo "Users, roles, and ACLs are configured."
echo "Create API tokens manually when needed."
