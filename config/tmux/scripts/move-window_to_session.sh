#!/usr/bin/env bash

if [[ $(tmux list-sessions -F '#S' | wc -l) -gt 1 ]] && [[ $(tmux list-windows |
  wc -l) -gt 1 ]]; then
  tmux list-sessions -F '#S' |
    grep -v "$(tmux display-message -p '#S')" |
    awk 'BEGIN {ORS=" "} {print $1, NR, "\"move-window -t", $1"; switch-client -t", $1 "\""}' |
    xargs tmux display-menu -T "Move window to session"
fi
