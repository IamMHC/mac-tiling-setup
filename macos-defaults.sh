#!/usr/bin/env bash
set -euo pipefail
# Optional macOS tweaks. Revert command is above each one.
# LOGOUT means it needs a logout to take effect.

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

# InitialKeyRepeat below ~20 makes a normal press auto-repeat, which
# double-fires toggle bindings.
# revert: defaults delete NSGlobalDomain KeyRepeat InitialKeyRepeat
say "Key repeat"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 25
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# revert: defaults delete NSGlobalDomain NSAutomaticWindowAnimationsEnabled
say "Window animations off"
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# revert: defaults delete com.apple.dock autohide mru-spaces
say "Dock out of the way, stop Spaces rearranging"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.dock mru-spaces -bool false

# Stop title-bar double-click minimising windows out from under the WM.
# revert: defaults delete NSGlobalDomain AppleActionOnDoubleClick
say "Double-click title bar does nothing"
defaults write NSGlobalDomain AppleActionOnDoubleClick -string "None"

# LOGOUT. Lets the bar own the top strip.
# revert: defaults write NSGlobalDomain _HIHideMenuBar -bool false
say "Hide the menu bar (LOGOUT required)"
defaults write NSGlobalDomain _HIHideMenuBar -bool true

# LOGOUT. AeroSpace expects displays to share Spaces.
# revert: defaults delete com.apple.spaces spans-displays
say "Displays share Spaces (LOGOUT required)"
defaults write com.apple.spaces spans-displays -bool true

killall Dock 2>/dev/null || true

cat <<'MSG'

Done. The last two settings need a logout to take effect.

If you would rather keep the menu bar visible, skip the logout and instead
offset the bar beneath it:
  sketchybar y_offset=32, and outer.top = 80 in ~/.aerospace.toml
MSG
