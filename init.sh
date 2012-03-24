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
    if [ ! -e "${HOME}/.$file" ]; then
        ln -s "${CONFIG_PATH}/$file" "${HOME}/.$file"
    fi
}

cd "$CONFIG_PATH"

for file in *; do
    if [ "$file" != "init.sh" ]; then
        link_config "$file"
    fi
done
