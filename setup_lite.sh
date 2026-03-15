#!/usr/bin/env bash

# Lightweight setup for remote servers
# Installs: fish, neovim (from source), rust CLI tools, go
# Skips: tmux config, i3, kitty, rofi, desktop apps, LSP tooling

set -e

SCRIPT_DIR=$PWD
CONFIG_DIR=$PWD/config

if ! sudo true; then
  exit 1
fi

# Install packages
sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y \
  curl \
  fd-find \
  fzf \
  git \
  jq \
  libclang-dev \
  libssl-dev \
  pkg-config \
  ripgrep \
  unzip \
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

# Install neovim nightly binary
NVIM_DIR="$HOME/.local/bin"
NVIM_BIN="$NVIM_DIR/nvim"
NVIM_TARBALL="nvim-linux-x86_64.tar.gz"
NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/$NVIM_TARBALL"

LATEST_SHA=$(curl -sL "https://github.com/neovim/neovim/releases/download/nightly/$NVIM_TARBALL.sha256sum" | awk '{print $1}')
CURRENT_SHA=""
if [[ -f "$NVIM_DIR/$NVIM_TARBALL.sha256" ]]; then
  CURRENT_SHA=$(cat "$NVIM_DIR/$NVIM_TARBALL.sha256")
fi

if [[ "$LATEST_SHA" != "$CURRENT_SHA" ]] || [[ ! -x "$NVIM_BIN" ]]; then
  echo "Downloading neovim nightly..."
  curl -Lo "/tmp/$NVIM_TARBALL" "$NVIM_URL"
  tar -xzf "/tmp/$NVIM_TARBALL" -C /tmp
  rm -rf "$NVIM_DIR/nvim-linux-x86_64"
  mv /tmp/nvim-linux-x86_64 "$NVIM_DIR/"
  ln -sf "$NVIM_DIR/nvim-linux-x86_64/bin/nvim" "$NVIM_BIN"
  echo "$LATEST_SHA" > "$NVIM_DIR/$NVIM_TARBALL.sha256"
  echo "Neovim nightly installed"
else
  echo "Neovim nightly already up to date, skipping"
fi

# FNM (node version manager)
if [[ -x "$HOME/.local/share/fnm/fnm" ]] || [[ -x "$(command -v fnm)" ]]; then
  echo "fnm already installed, skipping"
else
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi

# Rust toolchain (install before omf so ~/.cargo/env.fish exists when fish spawns)
if [[ ! -x "$(command -v rustc)" ]]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
else
  source "$HOME/.cargo/env"
  echo "Rust already installed ($(rustc --version)), skipping"
fi

# Install omf
if [[ ! -d $HOME/.local/share/omf ]]; then
  fish -c "curl -sL https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install > /tmp/omf-install.fish && fish /tmp/omf-install.fish --noninteractive"
fi

cargos=("eza" "du-dust" "procs" "tree-sitter-cli")
for cargo in "${cargos[@]}"; do
  if [[ ! -x "$(command -v "$cargo")" ]]; then
    cargo install "$cargo"
  fi
done

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
cd "$SCRIPT_DIR"
for script in scripts/*.sh; do
  bash "$script"
done

# Install neovim plugins
echo "Installing neovim plugins..."
NVIM_LIGHTWEIGHT=1 nvim --headless "+Lazy! sync" +qa
echo "Running plugin sync again..."
NVIM_LIGHTWEIGHT=1 nvim --headless "+Lazy! sync" +qa

# Save version lockfile
LOCKFILE="$SCRIPT_DIR/versions.json"
get_ver() { command -v "$1" &>/dev/null && "$@" 2>/dev/null | head -1 || echo "not installed"; }

jq -n \
  --arg date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg hostname "$(hostname)" \
  --arg nvim "$(get_ver nvim --version)" \
  --arg nvim_commit "$(git -C "$HOME/git/neovim" rev-parse --short HEAD 2>/dev/null || echo unknown)" \
  --arg fish "$(get_ver fish --version)" \
  --arg rustc "$(get_ver rustc --version)" \
  --arg cargo "$(get_ver cargo --version)" \
  --arg go "$(get_ver go version)" \
  --arg node "$(get_ver fnm current)" \
  --arg fnm "$(get_ver fnm --version)" \
  --arg gh "$(get_ver gh --version)" \
  --arg eza "$(get_ver eza --version)" \
  --arg dust "$(get_ver dust --version)" \
  --arg procs "$(get_ver procs --version)" \
  --arg ripgrep "$(get_ver rg --version)" \
  --arg fzf "$(get_ver fzf --version)" \
  --arg zoxide "$(get_ver zoxide --version)" \
  --arg lazygit "$(get_ver lazygit --version)" \
  --arg lazydocker "$(get_ver lazydocker --version)" \
  '{
    updated: $date,
    hostname: $hostname,
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
    lazydocker: $lazydocker
  }' > "$LOCKFILE"

echo ""
echo "Lite setup complete. Versions saved to $LOCKFILE"
if [[ "$NVIM_LIGHTWEIGHT" != "1" ]]; then
  echo "NVIM_LIGHTWEIGHT=1 has been set for fish shell."
  echo "Restart your shell or run: set -gx NVIM_LIGHTWEIGHT 1"
fi
