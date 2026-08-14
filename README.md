# mac-tiling-setup

A keyboard-driven tiling desktop for macOS. Nine workspaces, vim-key navigation,
a status bar, a focus ring, and a rendered calendar popup. Everything runs off
`⌥` (Option).

## Install

```bash
brew install iammhc/tap/mac-tiling-setup
mac-tiling-setup
```

The first command installs the tools. The second writes the configs. Nothing
touches your home directory until you run it.

From source:

```bash
git clone https://github.com/IamMHC/mac-tiling-setup.git
cd mac-tiling-setup
./install.sh
```

Requires macOS 13+, Homebrew, and `swiftc` (`xcode-select --install`).

Existing configs are copied to `~/.config/mac-tiling-setup-backup-<timestamp>/`
before anything is written. Safe to re-run.

### After installing

Grant Accessibility to AeroSpace, then **quit and reopen it**. The key listener
only attaches at launch, so permission granted to a running app leaves every
binding dead while the app otherwise looks fine.

Optional macOS tweaks (hidden menu bar, shared Spaces, faster key repeat):

```bash
mac-tiling-setup-defaults
```

The two display settings need a logout.

## Keybindings

```
⌥1..9          switch workspace          ⌥H J K L      move focus
⌥⇧1..9         send window to workspace  ⌥⇧H J K L     move window
⌥↩             terminal                  ⌥space        launcher
⌥V             float ⇄ tile              ⌥⇧F           fullscreen
⌥− / ⌥=        shrink / grow             ⌥⇧0           balance
⌥R             resize mode               ⌥⇧;           service mode
⌥⌃H / ⌥⌃L      focus other display       ⌥⌃⇧H / ⌥⌃⇧L   throw window across
⌥W             close window              ⌥tab          last workspace
```

## What it installs

| Tool | Role |
|---|---|
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | tiling window manager, own workspaces, no SIP disable |
| [SketchyBar](https://github.com/FelixKratz/SketchyBar) | status bar: workspaces, front app, clock, battery, volume |
| [JankyBorders](https://github.com/FelixKratz/JankyBorders) | focus ring around the active window |
| [icalBuddy](https://hasseg.org/icalBuddy/) | reads Calendar.app for the agenda |
| Raycast | launcher on `⌥space` (skip with `SKIP_RAYCAST=1`) |

## Dual monitor

Workspaces 1–5 pin to the external display, 6–9 to the built-in. Each entry
falls back through `secondary` then `main`, so unplugging the external collapses
everything onto the laptop and replugging restores it.

On a single display the pinning block is commented out at install time, with the
lines left in place for when you add one.

## Calendar popup

Click the clock. SketchyBar labels are single-line, so the day grid and agenda
are drawn as an image by a small Swift program.

```
sketchybar/calendar/CalendarCard.swift   renderer
sketchybar/plugins/clock_click.sh        icalBuddy -> calcard -> popup
```

Today is a filled accent disc. Under the divider, the next event is bright with
an accent dot and later ones are dim. With no calendar connected it reads
`Nothing scheduled`.

For events, add an account under System Settings > Internet Accounts and enable
Calendars. The next meeting then also appears in the bar, hidden on clear days.

Rebuild after editing:

```bash
cd ~/.config/sketchybar/calendar && swiftc -O -o calcard CalendarCard.swift
```

## Customising

Placeholders substituted by `install.sh`:

| Placeholder | Becomes |
|---|---|
| `__BREW__` | `brew --prefix`, so Intel and Apple silicon both work |
| `__HOME__` | your home directory |
| `__FONT__` | the resolved Nerd Font family name |
| `__EXTERNAL__` | your external display's name |

Edit the installed files, then reload:

```bash
aerospace reload-config            # or ⌥⇧; then esc
brew services restart sketchybar
```

**Apps.** Launcher bindings point at Ghostty, Brave, Zed and Slack. Change the
`⌥↩ / ⌥B / ⌥E / ⌥S` lines in `aerospace.toml`.

**Colours.** Tokyonight, set at the top of `sketchybarrc`, in `bordersrc`, and in
the palette block of `CalendarCard.swift`.

## Gotchas

**A floating window ignores tiling commands.** Resize refuses them outright.
Check with:

```bash
aerospace list-windows --all --format '%{app-name}|%{window-layout}'
```

Press `⌥V` on anything reading `floating`.

**Resize needs two windows.** It takes space from a sibling, so a lone window in
a workspace has nothing to take and the keys are silent no-ops.

**Native fullscreen is invisible to AeroSpace.** A green-button window gets its
own macOS Space where no binding fires. `⌥⇧F` handles this: Chromium and
Electron apps get their own fullscreen driven directly, everything else uses
AeroSpace. If you land in native fullscreen another way, `⌃⌘F` exits.

**Plugins use absolute paths deliberately.** SketchyBar and AeroSpace spawn
children with a minimal `PATH` that omits Homebrew, so a bare `sketchybar` call
fails silently and leaves the bar half-updated.

**The Nerd Font family name is not the cask name.** It registers as
`JetBrainsMono NF`; asking for `JetBrainsMono Nerd Font` renders nothing.
`install.sh` resolves it at install time.

## License

MIT.
