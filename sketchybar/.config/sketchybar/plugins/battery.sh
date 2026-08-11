#!/bin/bash
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

PERCENTAGE="$(pmset -g batt | grep -Eo '\d+%' | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ -z "$PERCENTAGE" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON="$BATTERY_100" ;;
  [6-8][0-9]) ICON="$BATTERY_75" ;;
  [3-5][0-9]) ICON="$BATTERY_50" ;;
  [1-2][0-9]) ICON="$BATTERY_25" ;;
  *) ICON="$BATTERY_0" ;;
esac

COLOR=$TEXT
if [ -n "$CHARGING" ]; then
  ICON="$BATTERY_CHARGING"
  COLOR=$GREEN
elif [ "$PERCENTAGE" -le 20 ]; then
  COLOR=$RED
fi

sketchybar --set battery icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
