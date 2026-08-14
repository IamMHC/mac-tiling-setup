#!/usr/bin/env bash
# Next event from Calendar.app. Hidden entirely when the day is clear.
SB=__BREW__/bin/sketchybar
IB=__BREW__/bin/icalBuddy

next=$("$IB" -n -nc -nrd -ea -eep "notes,url,location,attendees" \
        -df "" -tf "%H:%M" -b "" -ps "|@|" \
        eventsToday 2>/dev/null | head -1)

if [ -z "$next" ]; then
    "$SB" --set "$NAME" drawing=off
    exit 0
fi

title=${next%%|@|*}
time=${next#*|@|}
title=$(printf '%s' "$title" | cut -c1-28)

"$SB" --set "$NAME" drawing=on icon="󰃭" label="${time} ${title}"
