#!/bin/bash

BASENAME="${0##*/}"

if [ x"$1" != x ]; then
    CONFIG_PATH="$1"
elif [ -d "${HOME}/Dropbox/Personal/config" ]; then
    CONFIG_PATH="${HOME}/Dropbox/Personal/config"
elif [ -d "${HOME}/config" ]; then
    CONFIG_PATH="${HOME}/config"
else
    echo "Error: no config dir found"
    exit 1
fi

link_config() {
    file="$1"
    if [ -e "${HOME}/.$file" ]; then
        mkdir "${HOME}/original-dot-files" >/dev/null 2>/dev/null
        echo "Existing file found at $HOME/.$file, moving to ~/original-dot-files."
        mv ".$file" original-dot-files/
    fi
    ln -s "${CONFIG_PATH}/$file" "${HOME}/.$file"
}

cd "$CONFIG_PATH"

for file in *; do
    if [ "$file" != "init.sh" ]; then
        link_config "$file"
    fi
done
