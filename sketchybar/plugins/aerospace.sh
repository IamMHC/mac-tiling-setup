#!/usr/bin/env bash
# Absolute paths: plugins run with a minimal PATH that omits __BREW__/bin.
SB=__BREW__/bin/sketchybar
AS=__BREW__/bin/aerospace

# A no-op switch fires the callback with AEROSPACE_FOCUSED_WORKSPACE empty.
# Without the fallback every item compares against "" and clears its highlight.
focused="$FOCUSED_WORKSPACE"
[ -z "$focused" ] && focused="$("$AS" list-workspaces --focused 2>/dev/null)"

if [ "$1" = "$focused" ]; then
    "$SB" --set "$NAME" background.drawing=on label.color=0xff1a1b26
else
    "$SB" --set "$NAME" background.drawing=off label.color=0xff7f88ad
fi
