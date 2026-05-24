# Create Template VM

Run on the Proxmox node shell as `root`:

```bash
./scripts/check-host.sh
./scripts/create-template.sh
```

The script is based on the proven command sequence, adjusted from historical VMID `9000` to inventory VMID `9024`:

```bash
mkdir -p /root/proxmox-cloud-images
cd /root/proxmox-cloud-images
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
qm create 9024 --name ubuntu-2404-cloud-template --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci --bios ovmf --machine q35
qm set 9024 --scsi0 local-lvm:0,import-from=/root/proxmox-cloud-images/noble-server-cloudimg-amd64.img
qm resize 9024 scsi0 30G
qm set 9024 --efidisk0 local-lvm:0,pre-enrolled-keys=0
qm set 9024 --ide2 local-lvm:cloudinit
qm set 9024 --boot order=scsi0
qm set 9024 --ciuser ubuntu
qm set 9024 --ipconfig0 ip=dhcp
qm set 9024 --agent enabled=1
qm start 9024
```

Successful first-boot validation looked like this:

- `scsi0` exists in the VM hardware list and is available in `Options -> Boot Order`
- boot order is set to `scsi0`, not `net0`
- the VM reaches the Ubuntu login prompt in the Proxmox console

Do not convert the VM to a template yet.
