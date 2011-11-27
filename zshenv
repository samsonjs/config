path=($HOME/bin $HOME/apps/bin /usr/local/riak/bin /usr/local/bin /usr/local/sbin /opt/local/bin /opt/local/sbin $path)
[[ -e "$HOME/apps/android/tools" ]] && path=($HOME/apps/android/tools $path)
[[ -e "$HOME/apps/android/platform-tools" ]] && path=($HOME/apps/android/platform-tools $path)
[[ -e "$HOME/.rbenv/bin" ]] && path=($HOME/.rbenv/bin $path)

if [[ -d $HOME/apps/ ]]; then
    for bindir in $HOME/apps/*/bin(N); do
        path=($bindir $path)
    done
fi

ZDOTDIR=~/config/zsh

fpath=($fpath $ZDOTDIR/functions)
typeset -U fpath
