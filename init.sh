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
EXCLUDE_FILES=("init.sh" "zsh" "Brewfile" "CLAUDE.md" "gitignore")

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

# Symlink jj/config.toml into ~/.config/jj/. To override anything on a specific
# machine/account, drop any *.toml into ~/.config/jj/conf.d/ — jj loads that
# directory and it takes precedence over config.toml.
setup_jj_config() {
    local src="${CONFIG_PATH}/jj/config.toml"
    local dest="${HOME}/.config/jj/config.toml"

    if [ ! -f "$src" ]; then
        echo "Note: ${src} not found, skipping jj config link"
        return 0
    fi

    mkdir -p "${HOME}/.config/jj"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "✓ ${dest} already linked correctly"
        return 0
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Backing up existing ${dest} to ~/original-dot-files/"
        mkdir -p "${HOME}/original-dot-files"
        mv "$dest" "${HOME}/original-dot-files/jj-config.toml.$(date +%Y%m%d_%H%M%S)"
    fi

    ln -s "$src" "$dest"
    echo "→ Linked ${dest} to ${src}"
}

setup_jj_config

echo "Done!"
