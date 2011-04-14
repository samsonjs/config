path=($HOME/bin $HOME/apps/bin /usr/local/riak/bin /usr/local/narwhal/bin /usr/local/bin /usr/local/sbin /opt/local/bin /opt/local/sbin $path)
[[ -e "$HOME/apps/android/tools" ]] && path=($HOME/apps/android/tools $path)
[[ -e "$HOME/apps/android/platform-tools" ]] && path=($HOME/apps/android/platform-tools $path)
ZDOTDIR=~/config/zsh

fpath=($fpath $ZDOTDIR/functions)
typeset -U fpath
