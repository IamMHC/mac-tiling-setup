#!/usr/bin/env bash
set -euo pipefail

# Installs AeroSpace, SketchyBar, JankyBorders and icalBuddy, then writes the
# configs. Safe to re-run; existing configs are backed up first.

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.config/mac-tiling-setup-backup-$STAMP"

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m ! \033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m ✗ \033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- preflight

[ "$(uname -s)" = "Darwin" ] || die "macOS only."

command -v brew >/dev/null 2>&1 || die \
  "Homebrew required. Install from https://brew.sh then re-run."

BREW_PREFIX="$(brew --prefix)"
say "Homebrew prefix: $BREW_PREFIX"

command -v swiftc >/dev/null 2>&1 || die \
  "swiftc required for the calendar card. Install with: xcode-select --install"

# ---------------------------------------------------------------- packages

say "Installing packages (existing ones are skipped)"
brew install --cask nikitabobko/tap/aerospace          || true
brew install FelixKratz/formulae/sketchybar            || true
brew install FelixKratz/formulae/borders               || true
brew install ical-buddy                                || true
brew install --cask font-jetbrains-mono-nerd-font      || true

if [ "${SKIP_RAYCAST:-0}" != "1" ]; then
    brew install --cask raycast || true
fi

# ---------------------------------------------------------------- font name

# The registered family name differs from the cask name. Hardcoding it renders
# every label blank.
FONT_FAMILY="$(system_profiler SPFontsDataType 2>/dev/null \
    | grep -iE 'Family: JetBrainsMono NF$' | head -1 | sed 's/.*Family: //')"
if [ -z "$FONT_FAMILY" ]; then
    warn "JetBrainsMono Nerd Font family not found; falling back to Menlo."
    FONT_FAMILY="Menlo"
fi
say "Bar font: $FONT_FAMILY"

# ---------------------------------------------------------------- monitors

# Pinning is machine specific: pin 1-5 to a second display if there is one,
# otherwise ship the block commented out.
EXTERNAL=""
if command -v aerospace >/dev/null 2>&1 && aerospace list-monitors >/dev/null 2>&1; then
    EXTERNAL="$(aerospace list-monitors --format '%{monitor-name}' 2>/dev/null \
        | grep -v 'Built-in' | head -1)"
fi

if [ -n "$EXTERNAL" ]; then
    say "External display detected: $EXTERNAL  (workspaces 1-5 will pin to it)"
else
    say "Single display — workspace pinning left disabled"
fi

# ---------------------------------------------------------------- backup

backup_one() {
    local target="$1"
    [ -e "$target" ] || return 0
    mkdir -p "$BACKUP"
    local dest="$BACKUP/$(basename "$target")"
    cp -R "$target" "$dest"
    printf '   backed up %s -> %s\n' "$target" "$dest"
}

say "Backing up any existing config"
backup_one "$HOME/.aerospace.toml"
backup_one "$HOME/.config/aerospace"
backup_one "$HOME/.config/sketchybar"
backup_one "$HOME/.config/borders"
[ -d "$BACKUP" ] || printf '   nothing to back up\n'

# ---------------------------------------------------------------- install

# TOML has no variable expansion and plugins run with a minimal PATH, so
# absolute paths are baked in here.
render() {
    sed -e "s|__BREW__|$BREW_PREFIX|g" \
        -e "s|__HOME__|$HOME|g" \
        -e "s|__FONT__|$FONT_FAMILY|g" "$1"
}

mkdir -p "$HOME/.config/aerospace" \
         "$HOME/.config/sketchybar/plugins" \
         "$HOME/.config/sketchybar/calendar" \
         "$HOME/.config/borders"

say "Writing configs"

if [ -n "$EXTERNAL" ]; then
    render "$REPO/aerospace/aerospace.toml" \
      | sed "s|'__EXTERNAL__'|'$(printf '%s' "$EXTERNAL" | sed 's/[].*[\/&]/\\&/g')'|g" \
      > "$HOME/.aerospace.toml"
else
    # Comment out the pinning table, leaving a name someone can actually
    # replace when they add a display later.
    render "$REPO/aerospace/aerospace.toml" \
      | sed 's|__EXTERNAL__|YOUR-DISPLAY-NAME|g' \
      | awk '
          /^\[workspace-to-monitor-force-assignment\]/ {
              print "# Single display at install time. To pin workspaces once you"
              print "# add one, uncomment these and replace YOUR-DISPLAY-NAME with"
              print "# the output of: aerospace list-monitors"
              skip = 1
          }
          skip && /^$/ { skip = 0 }
          skip         { print "# " $0; next }
                       { print }
        ' > "$HOME/.aerospace.toml"
fi

render "$REPO/aerospace/fullscreen.sh" > "$HOME/.config/aerospace/fullscreen.sh"
render "$REPO/sketchybar/sketchybarrc" > "$HOME/.config/sketchybar/sketchybarrc"
render "$REPO/borders/bordersrc"       > "$HOME/.config/borders/bordersrc"

for p in "$REPO"/sketchybar/plugins/*.sh; do
    render "$p" > "$HOME/.config/sketchybar/plugins/$(basename "$p")"
done

cp "$REPO/sketchybar/calendar/CalendarCard.swift" \
   "$HOME/.config/sketchybar/calendar/CalendarCard.swift"

chmod +x "$HOME/.config/aerospace/fullscreen.sh" \
         "$HOME/.config/sketchybar/sketchybarrc" \
         "$HOME"/.config/sketchybar/plugins/*.sh \
         "$HOME/.config/borders/bordersrc"

# ---------------------------------------------------------------- build card

say "Compiling the calendar card renderer"
( cd "$HOME/.config/sketchybar/calendar" \
  && swiftc -O -o calcard CalendarCard.swift ) \
  || warn "calcard failed to build — the clock popup will not open"

# ---------------------------------------------------------------- services

say "Starting services"
brew services restart sketchybar >/dev/null 2>&1 || warn "sketchybar failed to start"
brew services restart borders    >/dev/null 2>&1 || warn "borders failed to start"
open -a AeroSpace 2>/dev/null || true
sleep 3
aerospace reload-config 2>/dev/null || true

# ---------------------------------------------------------------- next steps

cat <<EOF

$(say "Installed.")

Backup of any previous config:
  ${BACKUP/#$HOME/\~}

Two things you must do by hand:

  1. Grant Accessibility to AeroSpace
       System Settings > Privacy & Security > Accessibility > enable AeroSpace
     Then QUIT AND REOPEN AeroSpace. Its key listener only attaches at launch,
     so permission granted to a running app does nothing until it relaunches.

  2. Optional macOS tweaks (hidden menu bar, shared Spaces, fast key repeat):
       ./macos-defaults.sh
     These need a logout to take effect.

Optional, for calendar events in the bar:
  System Settings > Internet Accounts > add Google, enable Calendars.

Press alt-1 to alt-9 to switch workspaces. Full keymap in the README.
EOF
