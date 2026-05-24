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

TEST_VMID="${TEST_VMID:-2100}"
TEST_NAME="${TEST_NAME:-${TEMPLATE_NAME}-test}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this on the Proxmox node as root."
  exit 1
fi

if qm status "${TEST_VMID}" >/dev/null 2>&1; then
  echo "Test VMID ${TEST_VMID} already exists."
  exit 1
fi

qm clone "${TEMPLATE_VMID}" "${TEST_VMID}" --name "${TEST_NAME}" --full 1 --storage "${STORAGE}"
qm set "${TEST_VMID}" --ciuser "${CIUSER}" --ipconfig0 ip=dhcp --agent enabled=1

if [[ -n "${SSHKEY_FILE:-}" && -f "${SSHKEY_FILE}" ]]; then
  qm set "${TEST_VMID}" --sshkey "${SSHKEY_FILE}"
fi

qm start "${TEST_VMID}"
echo "Test VM ${TEST_VMID} started."
