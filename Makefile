.PHONY: install install-lite provision update-ip versions gh-tools \
       go-update cargo-update fish-update nvim-update lazy-utils \
       push help

# Detect environment: lite repo only has install_lite.sh, not install.sh
IS_LITE := $(shell test ! -f scripts/install.sh && echo 1)

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Run full install (workstation) or lite install (remote)
ifdef IS_LITE
	bash scripts/install_lite.sh
else
	bash scripts/install.sh
endif

provision: ## Provision jor1
	bash scripts/cloud/jor1-provision.sh

update-ip: ## Update Hetzner firewall with current IP
	bash scripts/cloud/hetzner-update-ip.sh

versions: ## Save version lockfile
ifdef IS_LITE
	bash scripts/save-versions.sh versions.json
else
	bash scripts/save-versions.sh versions.json --keyed
endif

gh-tools: ## Install/update GitHub release binaries
	bash scripts/gh-install.sh

gh-tools-force: ## Force reinstall all GitHub release binaries
	bash scripts/gh-install.sh --force

go-update: ## Update Go
	bash scripts/go-update.sh

cargo-update: ## Update Rust/Cargo packages
	bash scripts/cargo-update.sh

fish-update: ## Update fish plugins (omf + fisher)
	bash scripts/fish-update.sh

nvim-update: ## Update neovim (appimage + source build)
	bash scripts/nvim-update.sh

lazy-utils: ## Update lazygit/lazydocker
	bash scripts/lazy-utils-update.sh

push: ## Push dotfiles and sync repos
	fish -c 'dotfiles_push'
