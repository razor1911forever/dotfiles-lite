#!/usr/bin/env bash

if [ ! -d "$HOME/.local/share/omf" ]; then
  fish -c "omf install"
fi
fish -c "omf update"
fish -c "fisher update"
