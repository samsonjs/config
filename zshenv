path=($HOME/bin $HOME/apps/bin /usr/local/narwhal/bin /usr/local/bin /usr/local/sbin /opt/local/bin /opt/local/sbin $path)
ZDOTDIR=~/config/zsh

fpath=($fpath $ZDOTDIR/functions)
typeset -U fpath
