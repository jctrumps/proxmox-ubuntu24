#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

${SUDO} apt update
${SUDO} apt install -y qemu-guest-agent
${SUDO} systemctl enable qemu-guest-agent
${SUDO} cloud-init clean --logs
${SUDO} shutdown now
