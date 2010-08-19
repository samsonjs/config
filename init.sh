#!/bin/sh

BASENAME="${0##*/}"

if [ x"$1" != x ]; then
    CONFIG_PATH="$1"
else
    CONFIG_PATH="$HOME/config"
fi

for FILE in $CONFIG_PATH/*; do
    DOTFILE=".${FILE##*/}"
    if [ "$DOTFILE" = ".${BASENAME}" ]; then continue; fi
    if [ -e "$DOTFILE" ]; then
        mkdir original-dot-files >/dev/null 2>/dev/null
        echo "Existing file found at $DOTFILE, moving to ~/original-dot-files."
        mv "$DOTFILE" original-dot-files/
    fi
    ln -s "$FILE" "$DOTFILE"
done
