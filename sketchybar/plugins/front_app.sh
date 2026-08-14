#!/usr/bin/env bash
# Clicking empty bar space fires front_app_switched with an empty INFO.
# Fall back to the frontmost process instead of blanking the label.
SB=__BREW__/bin/sketchybar

[ "$SENDER" = "front_app_switched" ] || [ "$SENDER" = "forced" ] || exit 0

app="$INFO"
if [ -z "$app" ]; then
    app=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null)
fi

[ -n "$app" ] && "$SB" --set "$NAME" label="$app"
