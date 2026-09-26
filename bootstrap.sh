#!/bin/bash
#
# Bootstrap a fresh Mac. One line, from a terminal on the new machine:
#
#   bash -c "$(curl -fsSL https://git.samhuri.net/sjs/config/raw/branch/main/bootstrap.sh)"
#
# `bash -c "$(curl …)"` rather than `curl … | bash` so stdin stays the
# terminal: the second stage asks questions. Arguments pass through after `--`:
#
#   bash -c "$(curl -fsSL …/bootstrap.sh)" -- --roles dev,backup
#   bash -c "$(curl -fsSL …/bootstrap.sh)" -- --from thetis     # migrate ~/Developer and my apps
#
# This stage is the least that gets a stock macOS to a Ruby: the Command Line
# Tools, Homebrew, git, jj, rv and tea, clones of ~/config and ~/bin over HTTPS
# (both public, so no key yet), and the Ruby that bootstrap/ pins. Then it
# hands over to bootstrap/bootstrap.rb, which does the rest and can be re-run
# from the checkout any time. macOS only; Linux is a wish, not a plan.

set -euo pipefail

CONFIG_REMOTE="${BOOTSTRAP_CONFIG_REMOTE:-https://git.samhuri.net/sjs/config.git}"
BIN_REMOTE="${BOOTSTRAP_BIN_REMOTE:-https://git.samhuri.net/sjs/bin.git}"
CONFIG_DIR="${BOOTSTRAP_CONFIG_DIR:-$HOME/config}"
BIN_DIR="${BOOTSTRAP_BIN_DIR:-$HOME/bin}"

if [ "$(uname -s)" != "Darwin" ]; then
    echo "bootstrap: this is for macOS" >&2
    exit 1
fi

echo "== Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
    echo "✓ installed"
else
    # Opens the installer dialog; nothing to do but wait for it to finish.
    xcode-select --install
    until xcode-select -p >/dev/null 2>&1; do sleep 5; done
    echo "✓ installed"
fi

echo "== Homebrew"
case "$(uname -m)" in
    arm64) prefix=/opt/homebrew ;;
    *) prefix=/usr/local ;;
esac
if [ -x "$prefix/bin/brew" ]; then
    echo "✓ installed"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$("$prefix/bin/brew" shellenv)"

# zshrc guards every tool on `command_exists`, so brew has to be on PATH
# before it runs. ~/.zprofile is not in the repo because the prefix differs.
zprofile="$HOME/.zprofile"
line="eval \"\$($prefix/bin/brew shellenv zsh)\""
if ! grep -qsF "$line" "$zprofile"; then
    printf '\n%s\n' "$line" >> "$zprofile"
    echo "→ Added brew shellenv to $zprofile"
fi

# tea as well: stage two logs in to Forgejo with it before anything else
# needs a credential, and that comes before the Brewfile is applied.
echo "== git, jj, rv, tea"
brew install --quiet git jj rv tea

echo "== ~/config and ~/bin"
clone() {
    local remote="$1" dir="$2"
    if [ -d "$dir/.jj" ] || [ -d "$dir/.git" ]; then
        echo "✓ $dir"
    else
        jj git clone --colocate "$remote" "$dir"
    fi
}
clone "$CONFIG_REMOTE" "$CONFIG_DIR"
clone "$BIN_REMOTE" "$BIN_DIR"

echo "== Ruby"
version="$(tr -d '[:space:]' < "$CONFIG_DIR/bootstrap/.ruby-version")"
if ! ruby="$(rv ruby find "$version" 2>/dev/null)"; then
    rv ruby install --quiet "$version"
    ruby="$(rv ruby find "$version")"
fi
echo "✓ $ruby"

exec "$ruby" "$CONFIG_DIR/bootstrap/bootstrap.rb" "$@"
