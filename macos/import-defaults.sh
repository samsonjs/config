#!/bin/zsh
# Apply everything exported by export-defaults.sh. Replaces each key wholesale.
set -euo pipefail

HERE="${0:A:h}"
unlisted=()

for file in "$HERE"/shortcuts/*.plist; do
    domain=$(basename "$file" .plist)
    defaults write "$domain" NSUserKeyEquivalents "$(cat "$file")"
    # System Settings only lists apps registered here; the shortcuts work either way.
    # com.apple.universalaccess needs Full Disk Access to write, which a fresh
    # terminal doesn't have, so a failure here is reported rather than fatal.
    if [ "$domain" != NSGlobalDomain ] && \
       ! defaults read com.apple.universalaccess com.apple.custommenu.apps 2>/dev/null | grep -q "\"$domain\""; then
        defaults write com.apple.universalaccess com.apple.custommenu.apps -array-add "$domain" 2>/dev/null ||
            unlisted+=("$domain")
    fi
    echo "→ $domain NSUserKeyEquivalents"
done

if (( ${#unlisted} )); then
    echo "⚠️  Couldn't list ${unlisted[*]} in System Settings → Keyboard Shortcuts → App Shortcuts."
    echo "   Their shortcuts work regardless. To list them, give this terminal Full Disk Access and re-run."
fi

for file in "$HERE"/plists/*.plist; do
    name=$(basename "$file" .plist)
    domain=${name%.*}
    key=${name##*.}
    defaults write "$domain" "$key" "$(cat "$file")"
    echo "→ $domain $key"
done

echo "Done. Relaunch affected apps; log out and back in for system hotkeys."
