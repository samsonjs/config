#!/bin/sh

BASENAME="${0##*/}"

if [ x"$1" != x ]; then
    CONFIG_PATH="$1"
else
    CONFIG_PATH="${HOME}/config"
fi

ln -s "${CONFIG_PATH}/emacs"    ".emacs"
ln -s "${CONFIG_PATH}/emacs.d"  ".emacs.d"
ln -s "${CONFIG_PATH}/screenrc" ".screenrc"
ln -s "${CONFIG_PATH}/vimrc"    ".vimrc"
ln -s "${CONFIG_PATH}/zshenv"   ".zshenv"
