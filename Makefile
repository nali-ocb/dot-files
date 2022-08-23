
.PHONY: flake_nali
flake_shiryel:
	sudo nixos-rebuild switch --flake '.#desktop'

.PHONY: flake_nali_upgrade
flake_shiryel_upgrade:
	sudo nixos-rebuild switch --flake '.#desktop' --upgrade

.PHONY: config
config:
	sh './scripts/install.sh'
