#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${PROJECT_ROOT}/config/template.env"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Missing config/template.env"
  echo "Create it with: cp config/template.env.example config/template.env"
  exit 1
fi

# shellcheck source=/dev/null
source "${CONFIG_FILE}"

: "${TEMPLATE_VMID:?TEMPLATE_VMID is required}"
: "${TEMPLATE_NAME:?TEMPLATE_NAME is required}"
: "${IMAGE_URL:?IMAGE_URL is required}"
: "${IMAGE_FILE:?IMAGE_FILE is required}"
: "${IMAGE_DIR:?IMAGE_DIR is required}"
: "${STORAGE:?STORAGE is required}"
: "${BRIDGE:?BRIDGE is required}"
: "${CIUSER:?CIUSER is required}"

if [[ "${STORAGE}" != "local-lvm" && "${ALLOW_UNSAFE_STORAGE:-false}" != "true" ]]; then
  echo "Refusing to build on storage '${STORAGE}'."
  echo "This workflow only allows STORAGE=local-lvm by default because some backends fail during template conversion."
  echo "Set ALLOW_UNSAFE_STORAGE=true in config/template.env only after you verify the backend is safe for Proxmox templates."
  exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this on the Proxmox node as root."
  exit 1
fi

IMAGE_PATH="${IMAGE_DIR}/${IMAGE_FILE}"

if qm status "${TEMPLATE_VMID}" >/dev/null 2>&1; then
  if [[ "${ALLOW_DESTROY_EXISTING:-false}" == "true" ]]; then
    echo "Destroying existing VM/template ${TEMPLATE_VMID}"
    qm stop "${TEMPLATE_VMID}" >/dev/null 2>&1 || true
    qm destroy "${TEMPLATE_VMID}" --purge
  else
    echo "VMID ${TEMPLATE_VMID} already exists. Refusing to overwrite."
    echo "Set ALLOW_DESTROY_EXISTING=true in config/template.env to rebuild it."
    exit 1
  fi
fi

mkdir -p "${IMAGE_DIR}"

if [[ ! -f "${IMAGE_PATH}" || "${FORCE_IMAGE_DOWNLOAD:-false}" == "true" ]]; then
  echo "Downloading cloud image:"
  echo "  ${IMAGE_URL}"
  wget -O "${IMAGE_PATH}" "${IMAGE_URL}"
else
  echo "Using existing image: ${IMAGE_PATH}"
fi

echo "Creating VM ${TEMPLATE_VMID} (${TEMPLATE_NAME})"
qm create "${TEMPLATE_VMID}"   --name "${TEMPLATE_NAME}"   --memory "${MEMORY_MB}"   --cores "${CORES}"   --net0 "virtio,bridge=${BRIDGE}"   --scsihw virtio-scsi-single   --bios ovmf   --machine q35

qm set "${TEMPLATE_VMID}" --scsi0 "${STORAGE}:0,import-from=${IMAGE_PATH},iothread=1"
qm resize "${TEMPLATE_VMID}" scsi0 "${DISK_SIZE}"
qm set "${TEMPLATE_VMID}" --efidisk0 "${STORAGE}:0,pre-enrolled-keys=0"
qm set "${TEMPLATE_VMID}" --ide2 "${STORAGE}:cloudinit"
qm set "${TEMPLATE_VMID}" --boot order=scsi0
qm set "${TEMPLATE_VMID}" --ciuser "${CIUSER}"
qm set "${TEMPLATE_VMID}" --ipconfig0 ip=dhcp
qm set "${TEMPLATE_VMID}" --agent enabled=1

if [[ -n "${SSHKEY_FILE:-}" && -f "${SSHKEY_FILE}" ]]; then
  qm set "${TEMPLATE_VMID}" --sshkey "${SSHKEY_FILE}"
fi

if [[ "${ENABLE_SERIAL_CONSOLE:-false}" == "true" ]]; then
  qm set "${TEMPLATE_VMID}" --serial0 socket --vga serial0
fi

echo
echo "VM ${TEMPLATE_VMID} was created but NOT converted to a template yet."
echo "Next:"
echo "  1. Boot-test the VM."
echo "  2. Inside the guest, run the commands in docs/04-guest-prep.md."
echo "  3. After shutdown, run ./scripts/convert-to-template.sh"
echo

if [[ "${START_AFTER_CREATE:-true}" == "true" ]]; then
  qm start "${TEMPLATE_VMID}"
fi
