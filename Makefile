SHELL := /bin/bash

.PHONY: check create convert clone-test destroy permissions

check:
	./scripts/check-host.sh

create:
	./scripts/create-template.sh

convert:
	./scripts/convert-to-template.sh

clone-test:
	./scripts/clone-test-vm.sh

destroy:
	./scripts/destroy-template.sh

permissions:
	./scripts/setup-proxmox-automation-access.sh
