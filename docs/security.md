# Security Notes

Do not commit:

- API token secrets
- SSH private keys
- passwords
- custom cloud-init files containing real secrets

Before converting a VM to a template, clean the guest:

```bash
sudo apt update
sudo apt install -y qemu-guest-agent
sudo systemctl start qemu-guest-agent
systemctl is-active qemu-guest-agent
sudo cloud-init clean --logs --machine-id
sudo rm -f /etc/ssh/ssh_host_*
sudo shutdown now
```
