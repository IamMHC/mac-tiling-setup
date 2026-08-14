#!/usr/bin/env bash
SB=__BREW__/bin/sketchybar

# pointer left the bar — dismiss the calendar
if [ "$SENDER" = "mouse.exited.global" ]; then
    "$SB" --set clock popup.drawing=off
    exit 0
fi

"$SB" --set "$NAME" icon="󰃰" label="$(date '+%a %d %b  %H:%M')"
