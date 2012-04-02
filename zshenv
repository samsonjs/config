custom_paths=(/sbin /usr/sbin $HOME/bin $HOME/.rbenv/bin /usr/local/android/tools /usr/local/android/platform-tools /Applications/Xcode.app/Contents/Developer/usr/bin)
for dir in $custom_paths; do
    if [[ -d "$dir" ]]; then
        path=($dir $path)
    fi
done
export path
typeset -U path

[[ -d "$HOME/config/zsh" ]] && ZDOTDIR="$HOME/config/zsh"

fpath=($fpath $ZDOTDIR/functions)
typeset -U fpath

# source non-standard zshrc
. "$ZDOTDIR/zshrc"
