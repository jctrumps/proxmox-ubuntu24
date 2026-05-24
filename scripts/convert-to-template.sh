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
  exit 1
fi

STATUS="$(qm status "${TEMPLATE_VMID}" | awk '{print $2}')"
if [[ "${STATUS}" != "stopped" ]]; then
  echo "VM ${TEMPLATE_VMID} is ${STATUS}. Shutting it down."
  qm shutdown "${TEMPLATE_VMID}" || true
  echo "Waiting up to 120 seconds for shutdown..."
  for _ in $(seq 1 120); do
    STATUS="$(qm status "${TEMPLATE_VMID}" | awk '{print $2}')"
    [[ "${STATUS}" == "stopped" ]] && break
    sleep 1
  done
fi

STATUS="$(qm status "${TEMPLATE_VMID}" | awk '{print $2}')"
if [[ "${STATUS}" != "stopped" ]]; then
  echo "VM did not stop cleanly. Stop it manually before converting."
  exit 1
fi

qm template "${TEMPLATE_VMID}"
echo "Template conversion complete."
qm config "${TEMPLATE_VMID}" | sed -n '1,100p'
