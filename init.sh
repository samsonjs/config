#!/bin/sh

BASENAME="${0##*/}"

if [ x"$1" != x ]; then
    CONFIG_PATH="$1"
else
    CONFIG_PATH="${HOME}/config"
fi

[ -e ".ackrc"    ] || ln -s "${CONFIG_PATH}/ackrc"    ".ackrc"
[ -e ".emacs"    ] || ln -s "${CONFIG_PATH}/emacs"    ".emacs"
[ -e ".emacs.d"  ] || ln -s "${CONFIG_PATH}/emacs.d"  ".emacs.d"
[ -e ".screenrc" ] || ln -s "${CONFIG_PATH}/screenrc" ".screenrc"
[ -e ".vimrc"    ] || ln -s "${CONFIG_PATH}/vimrc"    ".vimrc"
[ -e ".zshenv"   ] || ln -s "${CONFIG_PATH}/zshenv"   ".zshenv"
