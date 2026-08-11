#!/bin/bash
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

VOLUME="$(osascript -e 'output volume of (get volume settings)')"
MUTED="$(osascript -e 'output muted of (get volume settings)')"

if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
  ICON="$VOLUME_0"
elif [ "$VOLUME" -lt 33 ]; then
  ICON="$VOLUME_10"
elif [ "$VOLUME" -lt 66 ]; then
  ICON="$VOLUME_33"
elif [ "$VOLUME" -lt 100 ]; then
  ICON="$VOLUME_66"
else
  ICON="$VOLUME_100"
fi

sketchybar --set volume icon="$ICON" label="${VOLUME}%"
