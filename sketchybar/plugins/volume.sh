#!/usr/bin/env bash
SB=__BREW__/bin/sketchybar

# Scroll over the item nudges volume by 5.
if [ "$SENDER" = "mouse.scrolled" ]; then
    [ -z "$SCROLL_DELTA" ] && exit 0
    CUR=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
    [ -z "$CUR" ] && exit 0
    if [ "${SCROLL_DELTA%%.*}" -gt 0 ] 2>/dev/null; then NEW=$((CUR + 5)); else NEW=$((CUR - 5)); fi
    [ "$NEW" -gt 100 ] && NEW=100
    [ "$NEW" -lt 0 ] && NEW=0
    osascript -e "set volume output volume $NEW" 2>/dev/null
    osascript -e "set volume output muted false" 2>/dev/null
    VOL=$NEW
elif [ "$SENDER" = "volume_change" ]; then
    VOL="$INFO"
else
    VOL=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
fi

[ -z "$VOL" ] && exit 0
MUTED=$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)

if [ "$MUTED" = "true" ] || [ "$VOL" -eq 0 ]; then
    ICON="󰝟"
else
    case "$VOL" in
        100|[6-9][0-9]) ICON="󰕾" ;;
        [3-5][0-9])     ICON="󰖀" ;;
        *)              ICON="󰕿" ;;
    esac
fi

"$SB" --set "$NAME" icon="$ICON" label="${VOL}%"
"$SB" --set volume_slider slider.percentage="$VOL"
