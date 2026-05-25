#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

${SUDO} apt update
${SUDO} apt install -y qemu-guest-agent
${SUDO} systemctl start qemu-guest-agent
systemctl is-active qemu-guest-agent
${SUDO} cloud-init clean --logs --machine-id
${SUDO} rm -f /etc/ssh/ssh_host_*
${SUDO} shutdown now
