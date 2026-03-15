#!/usr/bin/env bash

# Lightweight setup for remote servers
# Installs: fish, neovim (from source), rust CLI tools, go
# Skips: tmux config, i3, kitty, rofi, desktop apps, LSP tooling

set -e

CONFIG_DIR=$PWD/config

if ! sudo true; then
  exit 1
fi

# Install packages
sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y \
  build-essential \
  cmake \
  curl \
  fd-find \
  fzf \
  gettext \
  git \
  jq \
  ripgrep \
  zoxide

# Fish shell
if [[ ! -f /etc/apt/sources.list.d/fish-shell-ubuntu-release-4-noble.sources ]]; then
  sudo apt-add-repository ppa:fish-shell/release-4
  sudo apt-get update -q
fi
if [[ ! -x "$(command -v fish)" ]]; then
  sudo apt-get install fish -y -qq
fi

# Create directories
mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share"

# Symlink all configs in the repo
for dir in "$CONFIG_DIR"/*/; do
  name=$(basename "$dir")
  target="$HOME/.config/$name"
  [[ -L "$target" ]] && unlink "$target"
  [[ -d "$target" ]] && rm -rf "$target"
  ln -s "$dir" "$target"
done

# Build neovim nightly from source
NEOVIM_REPO=$HOME/git/neovim
if [[ ! -d $NEOVIM_REPO ]]; then
  mkdir -p "$HOME/git"
  cd "$HOME/git"
  git clone https://github.com/neovim/neovim.git
fi
cd "$NEOVIM_REPO"
git fetch --tags --force
git checkout nightly
sudo make clean
sudo make CMAKE_BUILD_TYPE=Release
sudo make install

# FNM (node version manager - needed for treesitter)
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

# Install omf
if [[ ! -d $HOME/.local/share/omf ]]; then
  fish -c "curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish"
fi

# Rust toolchain
if [[ ! -x "$(command -v rustc)" ]]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
rustup update

cargos=("eza" "du-dust" "procs")
for cargo in "${cargos[@]}"; do
  if [[ ! -x "$(command -v "$cargo")" ]]; then
    cargo install "$cargo"
  fi
done
if [[ ! -x "$(command -v yazi)" ]]; then
  cargo install --force yazi-build
fi

# Install gh
if [[ ! -x "$(command -v gh)" ]]; then
  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    sudo apt update &&
    sudo apt install gh -y
fi

# Set NVIM_LIGHTWEIGHT in fish if not already set
LITE_CONF="$HOME/.config/fish/conf.d/lite.fish"
if [[ ! -f "$LITE_CONF" ]] || ! grep -q NVIM_LIGHTWEIGHT "$LITE_CONF" 2>/dev/null; then
  echo 'set -gx NVIM_LIGHTWEIGHT 1' >>"$LITE_CONF"
fi

# Run scripts
for script in scripts/*.sh; do
  bash "$script"
done

echo ""
echo "Lite setup complete."
echo "NVIM_LIGHTWEIGHT=1 has been set for fish shell."
echo "Restart your shell or run: set -gx NVIM_LIGHTWEIGHT 1"
