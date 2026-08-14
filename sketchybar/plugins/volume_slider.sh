#!/usr/bin/env bash
# Dragging the slider sets the system volume. sketchybar hands the new
# position over in PERCENTAGE.
SB=__BREW__/bin/sketchybar

[ -z "$PERCENTAGE" ] && exit 0
osascript -e "set volume output volume $PERCENTAGE" 2>/dev/null
osascript -e "set volume output muted false" 2>/dev/null
"$SB" --set volume_slider slider.percentage="$PERCENTAGE"
"$SB" --trigger volume_change
