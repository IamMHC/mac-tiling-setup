#!/usr/bin/env bash
SB=__BREW__/bin/sketchybar

# Right click or a modifier mutes outright; plain click opens the slider.
if [ "$BUTTON" = "right" ] || [ "$MODIFIER" = "shift" ]; then
    osascript -e 'set volume output muted (not (output muted of (get volume settings)))'
    "$SB" --trigger volume_change
    exit 0
fi

VOL=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
"$SB" --set volume_slider slider.percentage="${VOL:-0}"
"$SB" --set volume popup.drawing=toggle
