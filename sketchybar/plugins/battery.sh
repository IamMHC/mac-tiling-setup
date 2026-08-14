#!/usr/bin/env bash
PCT=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHG=$(pmset -g batt | grep 'AC Power')
[ -z "$PCT" ] && exit 0
case ${PCT} in
  9[0-9]|100) ICON="󰁹";; [6-8][0-9]) ICON="󰂀";;
  [3-5][0-9]) ICON="󰁾";; [1-2][0-9]) ICON="󰁻";; *) ICON="󰁺";;
esac
[ -n "$CHG" ] && ICON="󰂄"
__BREW__/bin/sketchybar --set "$NAME" icon="$ICON" label="${PCT}%"
