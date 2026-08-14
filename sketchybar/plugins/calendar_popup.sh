#!/usr/bin/env bash
# Text fallback for the clock popup if calcard is unavailable.
SB=__BREW__/bin/sketchybar
IB=__BREW__/bin/icalBuddy
TODAY=$(date +%-d)

i=0
while IFS= read -r line; do
    if [ $i -gt 1 ]; then
        line=$(printf '%s' "$line" | sed -E "s/(^| )${TODAY}( |$)/[${TODAY}]/")
    fi
    "$SB" --set cal.$i label="$line" 2>/dev/null
    i=$((i + 1))
done < <(cal)
while [ $i -le 7 ]; do
    "$SB" --set cal.$i label=" " 2>/dev/null
    i=$((i + 1))
done

# Agenda rows
row=0
while IFS= read -r line; do
    [ $row -ge 6 ] && break
    "$SB" --set agenda.$row drawing=on label="$line" 2>/dev/null
    row=$((row + 1))
done < <("$IB" -n -nc -nrd -ea -eep "notes,url,attendees" -df "" -tf "%H:%M" \
          -b "· " -ps "|  |" eventsToday 2>/dev/null | cut -c1-34)

if [ $row -eq 0 ]; then
    "$SB" --set agenda.0 drawing=on label="no events today" 2>/dev/null
    row=1
fi
while [ $row -le 5 ]; do
    "$SB" --set agenda.$row drawing=off 2>/dev/null
    row=$((row + 1))
done
