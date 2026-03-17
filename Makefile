.PHONY: install install-lite provision update-ip versions gh-tools \
       go-update cargo-update fish-update nvim-update lazy-utils \
       push dothog help

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

provision: _auto-push ## Provision jor1
	bash scripts/cloud/jor1-provision.sh

provision-force: _auto-push ## Provision jor1 (skip confirmation)
	FORCE=1 bash scripts/cloud/jor1-provision.sh

_auto-push:
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "Unstaged changes detected, committing and pushing..."; \
		git add -A && git commit -m "Updating dotfiles" && git push; \
	fi

update-ip: ## Update Hetzner firewall with current IP
	bash scripts/cloud/jor1-update-ip.sh

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

dothog: ## Pull latest dothog image on jor1
	ssh jor1 'cd ~/git/dotfiles-lite/server && docker compose pull && docker compose up -d'

push: ## Push dotfiles and sync repos
	fish -c 'dotfiles_push'
