# Proven Build Notes

The original working sequence used VMID `9000`:

```bash
qm destroy 9000 --purge
cd /root
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
qm create 9000 --name ubuntu-2404-cloud-template --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci --bios ovmf --machine q35
qm set 9000 --scsi0 local-lvm:0,import-from=./noble-server-cloudimg-amd64.img
qm resize 9000 scsi0 30G
qm set 9000 --efidisk0 local-lvm:0,pre-enrolled-keys=0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot order=scsi0
qm set 9000 --ciuser ubuntu
qm start 9000
```

The project version uses VMID `9024`.

The missing step was guest preparation:

```bash
sudo apt update
sudo apt install -y qemu-guest-agent
sudo systemctl start qemu-guest-agent
systemctl is-active qemu-guest-agent
sudo cloud-init clean --logs --machine-id
sudo rm -f /etc/ssh/ssh_host_*
sudo shutdown now
```
