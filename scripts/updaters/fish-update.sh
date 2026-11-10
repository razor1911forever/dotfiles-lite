#!/usr/bin/env bash

set -e

STAMP="$HOME/.cache/fish-update-stamp"
INTERVAL=$((30 * 24 * 60 * 60)) # 30 days

if [[ -f "$STAMP" ]]; then
  LAST=$(stat -c %Y "$STAMP")
  NOW=$(date +%s)
  if (( NOW - LAST < INTERVAL )); then
    echo "Fish plugins updated less than 30 days ago, skipping"
    exit 0
  fi
fi

if [ ! -d "$HOME/.local/share/omf" ]; then
  fish -c "omf install"
fi
fish -c "omf update"

# Lite ships plugin files without Fisher's installed-plugin state. Running
# Fisher against those files causes conflicts and can delete fish_plugins.
# Match the Makefile's lite detection, including when run directly.
if [[ "${DOTFILES_LITE:-0}" == 1 || ! -f "$(dirname "${BASH_SOURCE[0]}")/../install.sh" ]]; then
  echo "Using bundled Fisher plugins in lite install, skipping Fisher update"
else
  fish -c "fisher update"
fi

mkdir -p "$(dirname "$STAMP")"
touch "$STAMP"
