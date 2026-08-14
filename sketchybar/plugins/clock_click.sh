#!/usr/bin/env bash
# Render the card, size the popup item to it, toggle.
# Rendering on open avoids a polling timer.
SB=__BREW__/bin/sketchybar
IB=__BREW__/bin/icalBuddy
DIR="$HOME/.config/sketchybar/calendar"
PNG="$DIR/card.png"

events=$("$IB" -n -nc -nrd -ea -eep "notes,url,location,attendees" \
          -df "" -tf "%H:%M" -b "" -ps "|\t|" eventsToday 2>/dev/null \
        | awk -F'\t' 'NF>=2 {print $2 "\t" $1; next} {print "\t" $0}')

read -r path w h < <(printf '%s\n' "$events" | "$DIR/calcard" "$PNG")

[ -n "$path" ] && "$SB" --set calcard \
    background.image="$path" \
    background.image.scale=0.5 \
    width="$w" \
    background.height="$h"

"$SB" --set clock popup.drawing=toggle
