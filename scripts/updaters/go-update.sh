#!/usr/bin/env bash

git_dir="$HOME/git"
repo_dir=$git_dir/update-golang
repo=https://github.com/udhos/update-golang

if [[ ! -d $git_dir ]]; then
  mkdir -p "$git_dir"
fi
if [[ ! -d $repo_dir ]]; then
  cd "$git_dir" || exit
  git clone "$repo"
fi

cd "$repo_dir" || exit
git pull

# Ensure go is in PATH
[[ -f /etc/profile.d/golang_path.sh ]] && source /etc/profile.d/golang_path.sh

# Check if Go needs updating
if command -v go &>/dev/null; then
  INSTALLED=$(go version 2>/dev/null | grep -oP 'go\K[0-9.]+')
  LATEST=$(wget --connect-timeout 5 -qO- https://go.dev/dl/?mode=json | jq -r '.[0].version' | sed 's/^go//')
  if [[ -n "$LATEST" && "$INSTALLED" == "$LATEST" ]]; then
    echo "Go already at latest ($INSTALLED), skipping"
  else
    sudo ./update-golang.sh
  fi
else
  sudo ./update-golang.sh
fi

[[ -f /etc/profile.d/golang_path.sh ]] && source /etc/profile.d/golang_path.sh
if ! command -v go &>/dev/null; then
  echo "go is not installed or not on PATH"
  exit 1
fi
export PATH="$(go env GOPATH)/bin:$PATH"

go install github.com/jorgerojas26/lazysql@latest
