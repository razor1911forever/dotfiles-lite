#!/usr/bin/env bash

BIN_PATH=$HOME/.local/bin

function file_changed_today() {
  return $(($(date +%s) - $(stat -c %Z "$1") < 86400))
}

function file_exists() {
  if [[ -f "$1" ]]; then
    return 1
  fi
  return 0
}

function can_update() {
  file_exists "$1"
  if [ $? == 1 ]; then
    file_changed_today "$1"
    return $?
  else
    return 1
  fi
}

function get_url() {
  if [ "$1" = "" ]; then
    exit 1
  fi
  url="https://github.com/neovim/neovim/releases/download/$1/nvim.appimage"
  echo "$url"
}

function do_update() {
  if [ "$1" = "" ]; then
    exit 1
  fi
  url=$(get_url "$1")
  img=$BIN_PATH/nvim.appimage.$1
  can_update "$img"
  can=$?
  if [ "$can" == 1 ]; then
    curl -Lo "$img" "$url"
    chmod u+x "$img"
    chmod +x "$img"
  fi
}

STABLE=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | jq '.tag_name' | cut -d\" -f2)
NIGHTLY=nightly

for version in "$STABLE" "$NIGHTLY"; do
  can_update "$BIN_PATH/nvim.appimage.$version"
  if [ $? == 1 ]; then
    do_update "$version"
  fi
done

NEOVIM_REPO=$HOME/git/neovim
if [[ -d $NEOVIM_REPO ]]; then
  cd "$NEOVIM_REPO" || exit
  BEFORE=$(git rev-parse HEAD 2>/dev/null || echo "none")
  git fetch --tags --force
  git checkout nightly
  AFTER=$(git rev-parse HEAD)
  if [[ "$BEFORE" != "$AFTER" ]]; then
    echo "Neovim changed ($BEFORE -> $AFTER), building..."
    sudo make clean && sudo make CMAKE_BUILD_TYPE=Release && sudo make install
  else
    echo "Neovim already up to date ($AFTER), skipping build"
  fi
fi
