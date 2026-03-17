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
  build-essential \
  ncurses-term \
  curl \
  fd-find \
  fzf \
  git \
  jq \
  nala \
  ripgrep \
  tmux \
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

# tmux conf and terminfo
if [[ -L "$HOME/.tmux.conf" ]]; then
  unlink "$HOME/.tmux.conf"
fi
ln -s "$CONFIG_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf" 2>/dev/null
tic "$CONFIG_DIR/tmux/terminfo/xterm-256color-italic.terminfo" 2>/dev/null || true

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
  sudo ln -sf "$NVIM_DIR/nvim-linux-x86_64/bin/nvim" /usr/local/bin/nvim
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

# Install omf
if [[ ! -d $HOME/.local/share/omf ]]; then
  fish -c "curl -sL https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install > /tmp/omf-install.fish && fish /tmp/omf-install.fish --noninteractive"
fi

# Install CLI tools from GitHub releases
bash "$SCRIPT_DIR/scripts/gh-install.sh"

# Install gh
if [[ ! -x "$(command -v gh)" ]]; then
  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    sudo apt update &&
    sudo apt install gh -y
fi

# Docker
if [[ ! -x "$(command -v docker)" ]]; then
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER"
else
  echo "Docker already installed, skipping"
fi

# Set lite fish config
LITE_CONF="$HOME/.config/fish/conf.d/lite.fish"
if [[ ! -f "$LITE_CONF" ]]; then
  cat > "$LITE_CONF" << 'EOF'
set -gx NVIM_LIGHTWEIGHT 1
fish_add_path -g $HOME/.local/bin
EOF
elif ! grep -q NVIM_LIGHTWEIGHT "$LITE_CONF" 2>/dev/null; then
  echo 'set -gx NVIM_LIGHTWEIGHT 1' >> "$LITE_CONF"
  echo 'fish_add_path -g $HOME/.local/bin' >> "$LITE_CONF"
fi

# Run scripts
cd "$SCRIPT_DIR"
for script in scripts/*.sh; do
  [[ "$(basename "$script")" == "save-versions.sh" ]] && continue
  [[ "$(basename "$script")" == "install_lite.sh" ]] && continue
  [[ "$(basename "$script")" == "gh-install.sh" ]] && continue
  bash "$script"
done

# Install neovim plugins
export PATH="$HOME/.local/bin:$PATH"
echo "Installing neovim plugins..."
NVIM_LIGHTWEIGHT=1 nvim --headless "+Lazy! sync" +qa
echo "Running plugin sync again..."
NVIM_LIGHTWEIGHT=1 nvim --headless "+Lazy! sync" +qa

# Save versions
bash "$SCRIPT_DIR/scripts/save-versions.sh" "$SCRIPT_DIR/versions.json"

echo ""
echo "Lite setup complete."
if [[ "$NVIM_LIGHTWEIGHT" != "1" ]]; then
  echo "NVIM_LIGHTWEIGHT=1 has been set for fish shell."
  echo "Restart your shell or run: set -gx NVIM_LIGHTWEIGHT 1"
fi
