#!/bin/bash

BASENAME="${0##*/}"

if [ x"$1" != x ]; then
    CONFIG_PATH="$1"
elif [ -d "${HOME}/config" ]; then
    CONFIG_PATH="${HOME}/config"
else
    echo "Error: no config dir found"
    exit 1
fi

link_config() {
    SRC="$1"
    NAME=$(basename "$SRC")
    DEST="${HOME}/.${NAME}"
    if [ -e "$DEST" ]; then
        echo "Existing file found at ${DEST}, moving to ~/original-dot-files."
        mkdir "${HOME}/original-dot-files" >/dev/null 2>/dev/null
        mv "$DEST" original-dot-files/
    fi
    ln -s "$SRC" "$DEST"
}

cd "$CONFIG_PATH"

for FILE in *; do
    if [ "$FILE" != "init.sh" ] && [ "$FILE" != "zsh" ] && [ "$FILE" != "Brewfile" ]; then
        link_config "${CONFIG_PATH}/$FILE"
    fi
done
