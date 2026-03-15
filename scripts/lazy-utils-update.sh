#!/usr/bin/env bash

function file_changed_in_days() {
  FILE=$1
  DAYS=${2:-30}
  if [[ $FILE == "" ]]; then
    return 0
  else
    return $(($(date +%s) - $(stat -c %Z "$FILE") < (86400 * DAYS)))
  fi
}

LAZYUTILS=(lazygit lazydocker)
for UTIL in "${LAZYUTILS[@]}"; do
  file_changed_in_days "$(which "$UTIL")" "$1"
  if [ $? != 1 ]; then
    echo "Updating $UTIL"
    TMP_DIR=$(mktemp -d /tmp/"$UTIL".XXXXXX)
    UTIL_INSTALL_PATH=$TMP_DIR/${UTIL}.tar.gz
    UTIL_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/${UTIL}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v*([^"]+)".*/\1/')
    curl -Lo "$UTIL_INSTALL_PATH" "https://github.com/jesseduffield/${UTIL}/releases/latest/download/${UTIL}_${UTIL_VERSION}_Linux_x86_64.tar.gz"
    sudo tar xf "$UTIL_INSTALL_PATH" -C /usr/local/bin "$UTIL"
    rm "$UTIL_INSTALL_PATH" -rf
    rm "$TMP_DIR" -rf
  fi
done
