# 0. Sniff out the platform
# =========================
uname=`uname -s`
function linux() { [[ "$uname" = "Linux"  ]] }
function mac()   { [[ "$uname" = "Darwin" ]] }

# check if a command is available
function command_exists() { which "$1" >/dev/null 2>/dev/null }

# check if this is an interactive session
# (tests if stdout is a tty)
function is_interactive() { [ -t 1 ] }

# 1. Environment Vars
# ===================
custom_paths=(/sbin /usr/sbin /Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin /usr/local/opt/mysql@5.6/bin /usr/local/bin /usr/local/sbin $HOME/bin)
for dir in $custom_paths; do
    if [[ -d "$dir" ]]; then
        path=($dir $path)
    fi
done
export path
typeset -U path

# remove / from word chars
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

[[ -d "$HOME/config/zsh" ]] && ZDOTDIR="$HOME/config/zsh"

fpath=($fpath $ZDOTDIR/functions $ZDOTDIR/completions)
typeset -U fpath

cdpath=(~)

HOSTNAME=`hostname -s`

if [[ "$INSIDE_EMACS" != "" ]] || [[ "$EMACS" = "t" ]]; then
    export PAGER=cat
    export MANPAGER=cat
else
    export PAGER='less'
    # most rocks
    if command_exists most; then
        export MANPAGER='most'
    fi
fi

if command_exists vim; then
    export EDITOR="vim"
    export VISUAL="vim"
else
    export EDITOR="vi"
    export VISUAL="vi"
fi

if mac; then
    # susv3 compliance over 10.3 - for riak and possibly building javascriptcore
    export COMMAND_MODE=unix2003

    # Don't pollute tar archives with ._ files (Apple double files)
    export COPYFILE_DISABLE=true

    export HOMEBREW_CASK_OPTS="--appdir=/Applications"

    # Set Apple Terminal.app resume directory
    if [[ $TERM_PROGRAM == "Apple_Terminal" ]] && [[ -z "$INSIDE_EMACS" ]] {
      function chpwd {
        local SEARCH=' '
        local REPLACE='%20'
        local PWD_URL="file://$HOSTNAME${PWD//$SEARCH/$REPLACE}"
        printf '\e]7;%s\a' "$PWD_URL"
      }

      chpwd
    }
fi

if [[ -r "$ZDOTDIR/zlocal" ]]; then
    source "$ZDOTDIR/zlocal"
fi

if [[ -d ~/Library/Mobile\ Documents/com\~apple\~CloudDocs ]]; then
    export icloud=~/Library/Mobile\ Documents/com\~apple\~CloudDocs
fi

# 4. Shell Options
# ================

# 4.1. Parameters and Shell Functionality
# ---------------------------------------
#setopt ignoreeof           # ignore EOF ('^D') (i.e. don't log out on it)
setopt braceccl             # {a-d} expands to a b c d
setopt noclobber            # don't overwrite existing files w/ > output redir
setopt hist_allow_clobber   # C-p or UP and command has >| now, ready to go

# 4.2. Changing Directories
# -------------------------
setopt autocd               # automatically cd to a directory if not cmd
setopt autopushd            # automatically pushd directories on dirstack
setopt nopushdsilent        # print dirstack after each cd/pushd
setopt pushdignoredups      # don't push dups on stack
setopt pushdminus           # pushd -N goes to Nth dir in stack
export DIRSTACKSIZE=8
setopt autonamedirs         # % export h=/home/sjs; cd ~h; pwd => /home/sjs
setopt cdablevars           # blah=~/media/movies; cd blah; pwd => ~/media/movies

# 4.3. Shell Completion
# ---------------------
setopt correct              # try to correct spelling...
setopt no_correctall        # ...only for commands, not filenames
setopt no_listbeep          # don't beep on ambiguous listings
setopt listpacked           # variable col widths (takes up less space)

# 4.4. Shell Expansion and Globbing
# ---------------------------------
setopt extendedglob         # use extended globbing (#, ~, ^)

# 4.5. History and History Expansion
# ----------------------------------
export HISTFILE="$ZDOTDIR/zhistory"    # save history
export HISTSIZE=2000000                # huge internal buffer
export SAVEHIST=2000000                # huge history file

setopt extendedhistory      # save timestamps in history
setopt no_histbeep          # don't beep for erroneous history expansions
setopt histignoredups       # ignore consecutive dups in history
setopt histfindnodups       # backwards search produces diff result each time
setopt histreduceblanks     # compact consecutive white space chars (cool)
setopt histnostore          # don't store history related functions
setopt incappendhistory     # incrementally add items to HISTFILE

# 4.6. Job Control
# ----------------
setopt longlistjobs         # list jobs in long format

# 4.7. Shell Prompt
# -----------------
setopt promptsubst          # allow paramater, command, so on in prompt
setopt transient_rprompt    # hide RPROMPT after cmdline is executed

# 4.8. ZLE
# --------
setopt no_beep          # don't beep on errors (in ZLE)

# when completing and then typing | > etc. don't delete
# the preceding space
self-insert-redir() {
    integer l=$#LBUFFER
    zle self-insert
    (( $l >= $#LBUFFER )) && LBUFFER[-1]=" $LBUFFER[-1]"
}
zle -N self-insert-redir
for op in \| \< \> \&
  do bindkey "$op" self-insert-redir
done

# 4.9. Auto quote pasted URLs
# ---------------------------
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

# 5. Terminal Settings
# ====================
function precmd {
    rehash
}
autoload -U colors            # we need the colors for some formats below
colors

# 6. ZLE Keybindings
# ==================
bindkey '\ep' history-beginning-search-backward

# 7. Prompt Subsystem
# ===================
# Load the prompt theme system
autoload -U promptinit
promptinit

# Use my prompt theme, based on wunjo (zsh-git)
prompt sjs

# 8. Aliases
# ===========

# 8.1. Convenience Aliases/Macros
# --------------------------------
alias bgd='bg; disown %1'
alias cp='nocorrect cp'            # don't correct spelling for 'cp'
alias e='mate'
alias ez="$EDITOR ~/.zshrc && source ~/.zshrc"

alias mkdir='nocorrect mkdir'      # don't correct spelling for 'mkdir'
alias mv='nocorrect mv'            # don't correct spelling for 'mv'
alias u='cd ..'
alias uu='cd ../..'
alias uuu='cd ../../..'
alias uuuu='cd ../../../..'
alias myip='curl icanhazip.com'

alias be='bundle exec'
alias doc='docker-compose'

# ls Aliases
# ----------------
if command_exists ls-comma; then
    alias ls='ls-comma'
fi
if mac; then
    gls_path=`which gls`
    if [[ -x "$gls_path" ]]; then
        alias ls='$gls_path -BF --color=auto'
        alias la='$gls_path -AF --color=auto'
    else
        alias ls='ls -BF'
        alias la='ls -AF'
    fi
else
    alias ls='ls -BF --color=auto'
    alias la='ls -AF --color=auto'
fi
alias ll='ls -l'
alias lsd='ls -d'
alias lld='ls -dl'

# ruby
alias irb='irb --readline -r irb/completion'

# git
if command_exists git; then
    alias a='git add'
    alias b='git branch'
    alias c='git commit'
    alias cam='git commit -a -m'
    alias co='git checkout'
    alias chp='git cherry-pick'
    alias d='git diff'
    alias dc='git diff --cached'
    alias dmcr='git diff-merge-conflict-resolution'
    alias ds='git diff --stat'
    alias ecf='git edit-conflicted-files mate'
    alias f='git fetch'
    alias gh='git open-in-github'
    alias glo='git log --oneline --decorate'
    alias gls='git log --stat'
    alias gup='git update'
    alias m='git merge'
    alias pfb='git push-feature-branch'
    alias rmb='git remove-merged-branches'
    alias s='git status -sb'
    alias st='git stash'
    alias stl='git stash list'
    alias stp='git stash pop'
    alias t='git tag'

    function gl() {
        git log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim   white)- %an%C(reset)%C(bold yellow)%d%C(reset)' "$@"
  }
fi

# `cd /path/to/a/file` does `cd /path/to/a`
function cd () {
    if [[ -f "$1" ]]; then
        builtin cd "${1:h}"
    elif [[ "$1" = "" ]]; then
        builtin cd
    else
        builtin cd "$1"
    fi
}

# 9. Unsorted (new) stuff
# =======================
# if commands takes more than 60 seconds tell me how long it took
export REPORTTIME=60

# set shell options
setopt no_badpattern            # supress err msgs
setopt cbases                   # 0xFF instead of 16#FF
setopt globsubst                # parameter expns eligible for filename expn & generation
setopt interactivecomments      # comments allowed in interactive shells
setopt no_hup                   # leave bg tasks running (a la nohup)

bindkey -e                      # emacs style key bindings

# 10. Completion
# =============
autoload -Uz compinit
compinit

# 11. SSH Keychain
# ================
if is_interactive && command_exists keychain && [[ -d ~/.ssh ]]; then
    if command_exists keychain; then
        keychain --nogui ~/.ssh/id_rsa*~*.pub(N)
        KEYCHAINFILE="$HOME/.keychain/$(hostname)-sh"
        if [[ -f $KEYCHAINFILE ]]; then
            source $KEYCHAINFILE >/dev/null
        fi
    elif command_exists ssh-add; then
        ssh-add
    fi
fi

# 12. rbenv and pyenv
# ===================
if command_exists rbenv; then
    eval "$(rbenv init -)"
fi
if command_exists pyenv; then
    eval "$(pyenv init -)"
fi

# 13. travis
# ==========
# added by travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh


# 15. screen
# ====================
# Automatically attach to a screen session.
function not_in_screen() {
    [[ "$STY" = "" ]] && [[ "$SHLVL" = "1" ]]
}

function is_screen_running() {
    NSCREENS="$(screen -ls | egrep 'Attached|Detached' | wc -l)"
    [[ "${NSCREENS// /}" != "0" ]]
}

if is_interactive && command_exists screen && not_in_screen && is_screen_running; then
    screen -rx
fi

if [[ -e ~/.opam ]]; then
    # OPAM configuration
    . ~/.opam/opam-init/init.zsh > /dev/null
fi

