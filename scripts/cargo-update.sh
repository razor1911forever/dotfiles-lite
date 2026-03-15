#!/usr/bin/env bash

STAMP="$HOME/.cache/cargo-update-stamp"
INTERVAL=$((30 * 24 * 60 * 60)) # 30 days

if [[ -f "$STAMP" ]]; then
  LAST=$(stat -c %Y "$STAMP")
  NOW=$(date +%s)
  if (( NOW - LAST < INTERVAL )); then
    echo "Cargo packages updated less than 30 days ago, skipping"
    exit 0
  fi
fi

# Install cargo-update
if [[ ! -x "$(command -v cargo-install-update)" ]]; then
  cargo install cargo-update
fi

# Update rust
rustup update

# Update all installed cargo packages
cargo install-update -a

mkdir -p "$(dirname "$STAMP")"
touch "$STAMP"
