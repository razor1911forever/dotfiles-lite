#!/usr/bin/env bash

# Install cargo-update
if [[ ! -x "$(command -v cargo-install-update)" ]]; then
  cargo install cargo-update
fi

# Update rust
rustup update

# Update all installed cargo packages
cargo install-update -a
