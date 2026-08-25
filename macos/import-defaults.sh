#!/bin/zsh
# Apply everything exported by export-defaults.sh. Replaces each key wholesale.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for file in "$HERE"/shortcuts/*.plist; do
    domain=$(basename "$file" .plist)
    defaults write "$domain" NSUserKeyEquivalents "$(cat "$file")"
    # System Settings only lists apps registered here; the shortcuts work either way.
    if [ "$domain" != NSGlobalDomain ] && \
       ! defaults read com.apple.universalaccess com.apple.custommenu.apps 2>/dev/null | grep -q "\"$domain\""; then
        defaults write com.apple.universalaccess com.apple.custommenu.apps -array-add "$domain"
    fi
    echo "→ $domain NSUserKeyEquivalents"
done

for file in "$HERE"/plists/*.plist; do
    name=$(basename "$file" .plist)
    domain=${name%.*}
    key=${name##*.}
    defaults write "$domain" "$key" "$(cat "$file")"
    echo "→ $domain $key"
done

echo "Done. Relaunch affected apps; log out and back in for system hotkeys."
