custom_paths=(/sbin /usr/sbin $HOME/bin $HOME/.rbenv/bin /usr/local/android/sdk/tools /usr/local/android/sdk/platform-tools /usr/local/bin /usr/local/share/npm/bin)
for dir in $custom_paths; do
    if [[ -d "$dir" ]]; then
        path=($dir $path)
    fi
done
if [[ -d /Applications/Xcode.app/Contents/Developer/usr/bin ]]; then
    path=($path /Applications/Xcode.app/Contents/Developer/usr/bin)
fi
export path
typeset -U path

[[ -d "$HOME/config/zsh" ]] && ZDOTDIR="$HOME/config/zsh"

fpath=($fpath $ZDOTDIR/functions)
typeset -U fpath

# source non-standard zshrc
. "$ZDOTDIR/zshrc"
