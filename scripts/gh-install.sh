#!/usr/bin/env bash

# Install binaries from GitHub releases
# Usage: gh-install.sh [--force]
#
# Downloads latest release binaries, skips if already at latest version.

set +e

BIN="$HOME/.local/bin"
mkdir -p "$BIN"
FORCE="${1:-}"

# Cache GitHub API responses to avoid rate limiting
declare -A API_CACHE

get_latest_tag() {
  local repo="$1"
  if [[ -z "${API_CACHE[$repo]}" ]]; then
    API_CACHE[$repo]=$(curl -s "https://api.github.com/repos/$repo/releases/latest")
  fi
  echo "${API_CACHE[$repo]}" | jq -r '.tag_name // empty' | sed 's/^v//'
}

get_download_url() {
  local repo="$1" pattern="$2"
  if [[ -z "${API_CACHE[$repo]}" ]]; then
    API_CACHE[$repo]=$(curl -s "https://api.github.com/repos/$repo/releases/latest")
  fi
  echo "${API_CACHE[$repo]}" | jq -r --arg pat "$pattern" '.assets[] | select(.name | test($pat)) | .browser_download_url' | head -1
}

install_gh_binary() {
  local cmd="$1" repo="$2" pattern="$3" version_cmd="${4:---version}" version_grep="${5:-[0-9]+\.[0-9]+}"

  local latest
  latest=$(get_latest_tag "$repo")

  if [[ -z "$latest" ]]; then
    echo "  $cmd: couldn't fetch latest version"
    return 1
  fi

  if [[ "$FORCE" != "--force" ]] && command -v "$cmd" &>/dev/null; then
    local installed
    installed=$("$cmd" $version_cmd 2>/dev/null | grep -oP "$version_grep" | head -1)
    if [[ "$installed" == "$latest" ]]; then
      echo "  $cmd: $installed (up to date)"
      return
    fi
    echo "  $cmd: $installed -> $latest"
  else
    echo "  $cmd: installing $latest"
  fi

  local url
  url=$(get_download_url "$repo" "$pattern")

  if [[ -z "$url" || "$url" == "null" ]]; then
    echo "  $cmd: no matching release for pattern '$pattern'"
    return 1
  fi

  local tmp
  tmp=$(mktemp -d "/tmp/$cmd.XXXXXX")
  curl -sL "$url" -o "$tmp/archive"

  case "$url" in
    *.tar.gz|*.tgz) tar -xzf "$tmp/archive" -C "$tmp" ;;
    *.zip)          unzip -qo "$tmp/archive" -d "$tmp" ;;
    *.gz)           gunzip -c "$tmp/archive" > "$tmp/$cmd" ;;
    *)              cp "$tmp/archive" "$tmp/$cmd" ;;
  esac

  find "$tmp" -name "$cmd" -type f | head -1 | xargs -I{} cp {} "$BIN/$cmd"
  chmod +x "$BIN/$cmd"
  rm -rf "$tmp"
  echo "  $cmd: installed $latest"
}

echo "Checking GitHub release binaries..."

#                    cmd          repo                         pattern                                    version_cmd    version_grep
install_gh_binary    eza          eza-community/eza            "x86_64-unknown-linux-gnu\\.tar\\.gz$"     "--version"    "[0-9]+\\.[0-9]+\\.[0-9]+"
install_gh_binary    dust         bootandy/dust                "x86_64-unknown-linux-gnu\\.tar\\.gz$"     "--version"    "[0-9]+\\.[0-9]+\\.[0-9]+"
install_gh_binary    procs        dalance/procs                "x86_64-linux\\.zip$"                      "--version"    "[0-9]+\\.[0-9]+\\.[0-9]+"
install_gh_binary    tree-sitter  tree-sitter/tree-sitter      "^tree-sitter-linux-x64\\.gz$"             "--version"    "[0-9]+\\.[0-9]+\\.[0-9]+"
install_gh_binary    lazygit      jesseduffield/lazygit        "linux_x86_64\\.tar\\.gz$"                 "--version"    "version=\\K[0-9]+\\.[0-9]+\\.[0-9]+"
install_gh_binary    lazydocker   jesseduffield/lazydocker     "Linux_x86_64\\.tar\\.gz$"                 "--version"    "Version: \\K[0-9]+\\.[0-9]+\\.[0-9]+"
install_gh_binary    yazi         sxyazi/yazi                  "yazi-x86_64-unknown-linux-gnu\\.zip$"     "--version"    "[0-9]+\\.[0-9]+\\.[0-9]+"
