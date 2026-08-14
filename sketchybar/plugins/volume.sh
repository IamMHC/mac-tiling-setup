#!/usr/bin/env bash
[ "$SENDER" != "volume_change" ] && exit 0
case ${INFO} in
  100|[6-9][0-9]) ICON="󰕾";; [3-5][0-9]) ICON="󰖀";;
  [1-9]|[1-2][0-9]) ICON="󰕿";; *) ICON="󰝟";;
esac
__BREW__/bin/sketchybar --set "$NAME" icon="$ICON" label="$INFO%"
