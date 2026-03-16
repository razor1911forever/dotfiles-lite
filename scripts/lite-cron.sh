#!/usr/bin/env bash

# Cron job to pull dotfiles-lite and run setup
# Install: crontab -e
# 0 4 * * * /home/jtye/git/dotfiles-lite/scripts/lite-cron.sh >> /tmp/dotfiles-lite-cron.log 2>&1

REPO="$HOME/git/dotfiles-lite"
LOGFILE="/tmp/dotfiles-lite-cron.log"

cd "$REPO" || exit 1

BEFORE=$(git rev-parse HEAD)
git pull --ff-only
AFTER=$(git rev-parse HEAD)

if [[ "$BEFORE" != "$AFTER" ]]; then
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) Changes detected ($BEFORE -> $AFTER), running setup..."
  ./install_lite.sh
else
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) No changes"
fi
