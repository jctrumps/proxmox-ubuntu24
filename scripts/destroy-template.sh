#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${PROJECT_ROOT}/config/template.env"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Missing config/template.env"
  exit 1
fi

# shellcheck source=/dev/null
source "${CONFIG_FILE}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this on the Proxmox node as root."
  exit 1
fi

if ! qm status "${TEMPLATE_VMID}" >/dev/null 2>&1; then
  echo "VMID ${TEMPLATE_VMID} does not exist."
  exit 0
fi

if [[ "${FORCE:-false}" != "true" ]]; then
  echo "Refusing to destroy ${TEMPLATE_VMID} unless FORCE=true is set."
  echo "Example: FORCE=true ./scripts/destroy-template.sh"
  exit 1
fi

qm stop "${TEMPLATE_VMID}" >/dev/null 2>&1 || true
qm destroy "${TEMPLATE_VMID}" --purge
echo "Destroyed VM/template ${TEMPLATE_VMID}."
