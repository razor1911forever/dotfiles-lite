#!/usr/bin/env bash

STAMP="$HOME/.cache/fish-update-stamp"
INTERVAL=$((30 * 24 * 60 * 60)) # 30 days

if [[ -f "$STAMP" ]]; then
  LAST=$(stat -c %Y "$STAMP")
  NOW=$(date +%s)
  if (( NOW - LAST < INTERVAL )); then
    echo "Fish plugins updated less than 24h ago, skipping"
    exit 0
  fi
fi

if [ ! -d "$HOME/.local/share/omf" ]; then
  fish -c "omf install"
fi
fish -c "omf update"
fish -c "fisher update"

mkdir -p "$(dirname "$STAMP")"
touch "$STAMP"
