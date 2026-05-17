#!/bin/bash

# Get the directory where this script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Use provided path or default to script directory
if [ -n "$1" ]; then
    CONFIG_PATH="$(cd "$1" && pwd)"
else
    CONFIG_PATH="$SCRIPT_DIR"
fi

if [ ! -d "$CONFIG_PATH" ]; then
    echo "Error: config directory not found: $CONFIG_PATH"
    exit 1
fi

link_config() {
    SRC="$1"
    NAME=$(basename "$SRC")
    DEST="${HOME}/.${NAME}"

    # Check if destination exists
    if [ -e "$DEST" ] || [ -L "$DEST" ]; then
        # If it's already a symlink pointing to the right place, skip it
        if [ -L "$DEST" ] && [ "$(readlink "$DEST")" = "$SRC" ]; then
            echo "✓ ${DEST} already linked correctly"
            return 0
        fi

        # Otherwise, back it up
        echo "Backing up existing ${DEST} to ~/original-dot-files/"
        mkdir -p "${HOME}/original-dot-files"
        mv "$DEST" "${HOME}/original-dot-files/${NAME}.$(date +%Y%m%d_%H%M%S)"
    fi

    # Create the symlink
    ln -s "$SRC" "$DEST"
    echo "→ Linked ${DEST} to ${SRC}"
}

# Files to exclude from symlinking
EXCLUDE_FILES=("init.sh" "zsh" "Brewfile", "CLAUDE.md")

echo "Creating symlinks from ${CONFIG_PATH}..."

for FILE in "$CONFIG_PATH"/*; do
    BASENAME=$(basename "$FILE")

    # Skip if file is in exclude list
    SKIP=false
    for EXCLUDE in "${EXCLUDE_FILES[@]}"; do
        if [ "$BASENAME" = "$EXCLUDE" ]; then
            SKIP=true
            break
        fi
    done

    if [ "$SKIP" = false ] && [ -f "$FILE" ]; then
        link_config "$FILE"
    fi
done

setup_jj_identity() {
    if ! command -v jj >/dev/null 2>&1; then
        echo "Note: jj is not installed, skipping jj identity setup"
        return 0
    fi

    if [ -z "$(jj config get user.name 2>/dev/null)" ]; then
        jj config set --user user.name "Sami Samhuri"
        echo "→ Set jj user.name"
    else
        echo "✓ jj user.name already set"
    fi

    if [ -z "$(jj config get user.email 2>/dev/null)" ]; then
        jj config set --user user.email "sami@samhuri.net"
        echo "→ Set jj user.email"
    else
        echo "✓ jj user.email already set"
    fi
}

# Prefer the "github" remote over the default "origin" everywhere jj defaults
# to it: trunk() resolution, git push, git fetch. The trunk() alias is a
# fallback chain — repo-level trunk() (written by jj at init) still wins.
setup_jj_github_defaults() {
    if ! command -v jj >/dev/null 2>&1; then
        return 0
    fi

    local trunk_alias='latest(present(main@github) | present(master@github) | present(main@origin) | present(master@origin) | root())'

    if [ "$(jj config get 'revset-aliases."trunk()"' 2>/dev/null)" = "$trunk_alias" ]; then
        echo "✓ jj trunk() alias already set"
    else
        jj config set --user 'revset-aliases."trunk()"' "$trunk_alias"
        echo "→ Set jj trunk() alias to prefer github"
    fi

    if [ "$(jj config get git.push 2>/dev/null)" = "github" ]; then
        echo "✓ jj git.push already set to github"
    else
        jj config set --user git.push github
        echo "→ Set jj git.push to github"
    fi

    if [ "$(jj config get git.fetch 2>/dev/null)" = "github" ]; then
        echo "✓ jj git.fetch already set to github"
    else
        jj config set --user git.fetch github
        echo "→ Set jj git.fetch to github"
    fi
}

setup_jj_identity
setup_jj_github_defaults

echo "Done!"
