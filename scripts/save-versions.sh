#!/usr/bin/env bash

# Save tool versions to versions.json
# Usage: save-versions.sh <lockfile> [--keyed]
#   --keyed: store under hostname key (for multi-host dotfiles)

set -e

LOCKFILE="${1:?Usage: save-versions.sh <lockfile> [--keyed]}"
KEYED="${2:-}"
HOSTNAME=$(hostname)

get_ver() { command -v "$1" &>/dev/null && "$@" 2>/dev/null | head -1 || echo "not installed"; }

# Source go path if available
[[ -f /etc/profile.d/golang_path.sh ]] && source /etc/profile.d/golang_path.sh
# Source cargo if available
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

VERSIONS=$(jq -n \
  --arg date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg nvim "$(get_ver nvim --version)" \
  --arg nvim_commit "$(git -C "$HOME/git/neovim" rev-parse --short HEAD 2>/dev/null || echo unknown)" \
  --arg fish "$(get_ver fish --version)" \
  --arg rustc "$(get_ver rustc --version)" \
  --arg cargo "$(get_ver cargo --version)" \
  --arg go "$(get_ver go version)" \
  --arg node "$(get_ver fnm current)" \
  --arg fnm "$(get_ver fnm --version)" \
  --arg gh "$(get_ver gh --version)" \
  --arg eza "$(eza --version 2>/dev/null | sed -n '2p' || echo 'not installed')" \
  --arg dust "$(get_ver dust --version)" \
  --arg procs "$(get_ver procs --version)" \
  --arg ripgrep "$(get_ver rg --version)" \
  --arg fzf "$(get_ver fzf --version)" \
  --arg zoxide "$(get_ver zoxide --version)" \
  --arg lazygit "$(get_ver lazygit --version)" \
  --arg lazydocker "$(get_ver lazydocker --version)" \
  --arg yazi "$(get_ver yazi --version)" \
  '{
    updated: $date,
    nvim: $nvim,
    nvim_commit: $nvim_commit,
    fish: $fish,
    rustc: $rustc,
    cargo: $cargo,
    go: $go,
    node: $node,
    fnm: $fnm,
    gh: $gh,
    eza: $eza,
    dust: $dust,
    procs: $procs,
    ripgrep: $ripgrep,
    fzf: $fzf,
    zoxide: $zoxide,
    lazygit: $lazygit,
    lazydocker: $lazydocker,
    yazi: $yazi
  }')

if [[ "$KEYED" == "--keyed" ]]; then
  # Merge into existing file keyed by hostname
  if [[ -f "$LOCKFILE" ]]; then
    EXISTING=$(cat "$LOCKFILE")
  else
    EXISTING="{}"
  fi
  echo "$EXISTING" | jq --arg host "$HOSTNAME" --argjson ver "$VERSIONS" '.[$host] = $ver' > "$LOCKFILE"
else
  echo "$VERSIONS" > "$LOCKFILE"
fi
