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
sudo ./update-golang.sh
