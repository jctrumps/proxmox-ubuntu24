# Configuration

Copy and edit:

```bash
cp config/template.env.example config/template.env
nano config/template.env
```

Key values:

```bash
TEMPLATE_VMID=9024
TEMPLATE_NAME="ubuntu-2404-cloudinit"
STORAGE="local-lvm"
BRIDGE="vmbr0"
CIUSER="ubuntu"
ALLOW_UNSAFE_STORAGE=false
SSHKEY_FILE=""
```

Notes:

- `local-lvm` is the only allowed template-build storage by default
- set `ALLOW_UNSAFE_STORAGE=true` only after you verify the backend supports Proxmox template conversion safely
- set `SSHKEY_FILE` only if you want the create/clone scripts to inject a public key automatically
