#!/usr/bin/env bash
# Fullscreen toggle.
# Chromium/Electron run their own fullscreen and desync AeroSpace, so toggle
# AXFullScreen on their real window. Everything else uses AeroSpace.

AS=__BREW__/bin/aerospace

read -r bundle app < <("$AS" list-windows --focused --format '%{app-bundle-id} %{app-name}' 2>/dev/null)

case "$bundle" in
    com.brave.Browser* | \
    com.google.Chrome* | \
    com.microsoft.edgemac* | \
    com.vivaldi.Vivaldi | \
    company.thebrowser.Browser | \
    com.electron.* | \
    com.tinyspeck.slackmacgap | \
    dev.zed.Zed* | \
    com.docker.docker | \
    com.figma.Desktop | \
    notion.id | \
    com.spotify.client)
        osascript <<OSA
tell application "System Events" to tell process "$app"
    -- Exiting fullscreen destroys the helper strips, invalidating the window
    -- list mid-loop. Set the first match and bail out.
    repeat with w in windows
        try
            if value of attribute "AXFullScreen" of w is true then
                set value of attribute "AXFullScreen" of w to false
                return "exited"
            end if
        end try
    end repeat

    -- Enter on the tallest window; the ~40px helper strips are decoys.
    -- Index-based because window refs go stale.
    set n to count of windows
    set best to 0
    set tallest to 0
    repeat with i from 1 to n
        try
            -- bind first; indexing inline reads as a specifier and fails
            set s to size of window i
            set h to item 2 of s
            if h > tallest then
                set tallest to h
                set best to i
            end if
        end try
    end repeat
    if best > 0 then
        set value of attribute "AXFullScreen" of window best to true
        return "entered"
    end if
    return "no window"
end tell
OSA
        ;;
    *)
        "$AS" fullscreen
        ;;
esac
