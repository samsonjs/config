#!/bin/sh

BASENAME="${0##*/}"

if [ x"$1" != x ]; then
    CONFIG_PATH="$1"
else
    CONFIG_PATH="${HOME}/config"
fi

link_config() {
    file="$1"
    [ -e ".$file" ] || ln -s "${CONFIG_PATH}/$file" ".$file"
}

CONFIG_FILES="ackrc emacs emacs.d gitconfig screenrc vimrc zshenv gdbinit"

for file in $CONFIG_FILES; do
    link_config "$file"
done
