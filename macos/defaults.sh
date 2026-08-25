#!/bin/zsh
# Apply my non-default macOS system settings. Idempotent; run on a new machine
# after init.sh, then log out and back in (or at least restart Finder/Dock).
#
# Not covered here: per-app custom menu shortcuts and disabled system hotkeys
# (see import-defaults.sh), Caps Lock -> Control (per-keyboard, set it by hand),
# text replacements (iCloud), Dock contents (differs per machine).
set -euo pipefail

echo "Keyboard & text"
defaults write -g AppleKeyboardUIMode -int 2                 # tab moves focus between all controls
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool true
defaults write -g NSAutomaticDashSubstitutionEnabled -bool true
defaults write -g NSAutomaticInlinePredictionEnabled -bool true
defaults write com.apple.HIToolbox AppleFnUsageType -int 0   # fn key does nothing
defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 1

echo "Trackpad & mouse"
defaults write -g AppleEnableSwipeNavigateWithScrolls -bool false   # no two-finger swipe for back/forward
defaults write -g com.apple.trackpad.scaling -int 3
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseTwoFingerDoubleTapGesture -int 3  # Mission Control
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseOneFingerDoubleTapGesture -int 0  # no smart zoom

echo "Appearance & windows"
defaults write -g AppleInterfaceStyleSwitchesAutomatically -bool true
defaults write -g NSGlassDiffusionSetting -int 0
defaults write -g AppleMiniaturizeOnDoubleClick -bool false
defaults write -g AppleSpacesSwitchOnActivate -bool false    # don't jump spaces when switching apps
defaults write -g AppleShowAllExtensions -bool true
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager HideDesktop -bool true
defaults write com.apple.WindowManager StandardHideWidgets -bool false
defaults write com.apple.menuextra.clock ShowSeconds -bool true
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowDate -int 0
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.Siri StatusMenuVisible -bool false

echo "Dock & hot corners"
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false          # don't rearrange spaces by recent use
defaults write com.apple.dock wvous-bl-corner -int 10         # bottom-left: put display to sleep
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 5          # bottom-right: start screen saver
defaults write com.apple.dock wvous-br-modifier -int 0

echo "Finder"
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv   # list view
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowSidebar -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXDefaultSearchScope -string SCcf   # search current folder
defaults write com.apple.finder NewWindowTarget -string PfHm        # new windows open home
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
defaults write com.apple.finder FXRemoveOldTrashItems -bool true    # empty trash after 30 days

echo "Screenshots"
defaults write com.apple.screencapture showsClicks -bool true

killall Dock Finder SystemUIServer 2>/dev/null || true
echo "Done. Log out and back in for keyboard/trackpad changes to fully apply."
