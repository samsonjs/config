# macOS settings

Run after `init.sh` on a new machine:

    ./defaults.sh          # system settings as `defaults write` lines
    ./import-defaults.sh   # dictionary-valued settings from plists/ and shortcuts/

Then log out and back in.

`export-defaults.sh` refreshes `plists/` and `shortcuts/` from the current
machine so changes can be committed.

## What's where

- `defaults.sh` — keyboard/text, trackpad, appearance, window tiling, hot
  corners, Finder, screenshots. Edit by hand.
- `shortcuts/<bundle-id>.plist` — System Settings › Keyboard › App Shortcuts,
  one file per app (`NSUserKeyEquivalents`). Modifier legend: `@` ⌘, `~` ⌥,
  `^` ⌃, `$` ⇧. Menu titles must match exactly, including `...`.
- `plists/com.apple.symbolichotkeys.AppleSymbolicHotKeys.plist` — system-wide
  hotkeys, including which ones are disabled.

Deliberately not here: Caps Lock → Control (per-keyboard ID, set it by hand),
text replacements (iCloud), Dock contents/size (per machine). Xcode's own
Settings › Key Bindings live in
`~/Library/Developer/Xcode/UserData/KeyBindings/*.idekeybindings`.
