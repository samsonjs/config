#!/bin/bash
# Dump dictionary-valued settings that are impractical as `defaults write` lines:
#   shortcuts/<bundle-id>.plist   custom app menu shortcuts (NSUserKeyEquivalents)
#   plists/<domain>.<key>.plist   other whole-dictionary keys listed in KEYS below
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$HERE/shortcuts" "$HERE/plists"

KEYS=(
    "com.apple.symbolichotkeys AppleSymbolicHotKeys"   # system-wide hotkeys, incl. which are disabled
)

domains=$(defaults find NSUserKeyEquivalents 2>/dev/null \
    | sed -n "s/^Found [0-9]* keys in domain '\(.*\)':.*/\1/p")
if defaults read -g NSUserKeyEquivalents >/dev/null 2>&1; then
    domains="$domains"$'\n'"NSGlobalDomain"
fi
for domain in $domains; do
    out="$HERE/shortcuts/$domain.plist"
    defaults export "$domain" - | plutil -extract NSUserKeyEquivalents xml1 -o "$out" -
    echo "→ $domain ($(plutil -p "$out" | grep -c '=>') shortcuts)"
done

for entry in "${KEYS[@]}"; do
    read -r domain key <<<"$entry"
    out="$HERE/plists/$domain.$key.plist"
    defaults export "$domain" - | plutil -extract "$key" xml1 -o "$out" -
    echo "→ $domain $key"
done
