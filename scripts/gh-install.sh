#!/usr/bin/env bash

# Install binaries from GitHub releases
# Usage: gh-install.sh [--force]
#
# Reads a list of tools and downloads their latest release binaries.
# Skips tools that are already installed unless --force is passed.

set -e

BIN="$HOME/.local/bin"
mkdir -p "$BIN"
FORCE="${1:-}"

install_gh_binary() {
  local cmd="$1" repo="$2" pattern="$3" extract_path="${4:-}"

  if [[ "$FORCE" != "--force" ]] && command -v "$cmd" &>/dev/null; then
    echo "  $cmd: already installed, skipping"
    return
  fi

  local url
  url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" \
    | jq -r ".assets[] | select(.name | test(\"$pattern\")) | .browser_download_url" \
    | head -1)

  if [[ -z "$url" || "$url" == "null" ]]; then
    echo "  $cmd: no matching release found for pattern '$pattern'"
    return 1
  fi

  echo "  $cmd: downloading from $repo..."
  local tmp
  tmp=$(mktemp -d "/tmp/$cmd.XXXXXX")

  curl -sL "$url" -o "$tmp/archive"

  case "$url" in
    *.tar.gz|*.tgz)
      tar -xzf "$tmp/archive" -C "$tmp"
      ;;
    *.zip)
      unzip -qo "$tmp/archive" -d "$tmp"
      ;;
    *.gz)
      gunzip -c "$tmp/archive" > "$tmp/$cmd"
      ;;
    *)
      cp "$tmp/archive" "$tmp/$cmd"
      ;;
  esac

  if [[ -n "$extract_path" ]]; then
    cp "$tmp/$extract_path" "$BIN/$cmd"
  else
    find "$tmp" -name "$cmd" -type f | head -1 | xargs -I{} cp {} "$BIN/$cmd"
  fi

  chmod +x "$BIN/$cmd"
  rm -rf "$tmp"
  echo "  $cmd: installed"
}

echo "Installing tools from GitHub releases..."

# tool               repo                            asset pattern                              extract path (optional)
install_gh_binary    eza          eza-community/eza          "x86_64-unknown-linux-gnu\\.tar\\.gz$"
install_gh_binary    dust         bootandy/dust              "x86_64-unknown-linux-gnu\\.tar\\.gz$"
install_gh_binary    procs        dalance/procs              "x86_64-linux\\.zip$"
install_gh_binary    tree-sitter  tree-sitter/tree-sitter    "linux-x64\\.gz$"
install_gh_binary    lazygit      jesseduffield/lazygit      "Linux_x86_64\\.tar\\.gz$"
install_gh_binary    lazydocker   jesseduffield/lazydocker   "Linux_x86_64\\.tar\\.gz$"
install_gh_binary    yazi         sxyazi/yazi                "x86_64-unknown-linux-gnu\\.zip$"
