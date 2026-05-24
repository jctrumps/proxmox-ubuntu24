# Validation

After the VM shuts down:

```bash
./scripts/convert-to-template.sh
qm config 9024
```

Expected:

- `template: 1`
- `scsi0` on `local-lvm`
- `ide2` cloud-init drive
- `ciuser: ubuntu`
- `agent: enabled=1`
- `bios: ovmf`
- `machine: q35`

Optional test clone:

```bash
./scripts/clone-test-vm.sh
```

Downstream validation:

- this template was successfully consumed by a separate project
- the resulting VM booted and was usable without additional template fixes
