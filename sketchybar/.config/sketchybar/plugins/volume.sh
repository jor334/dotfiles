#!/bin/bash
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

VOLUME="$(osascript -e 'output volume of (get volume settings)')"
MUTED="$(osascript -e 'output muted of (get volume settings)')"

if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
  ICON="$VOLUME_MUTE"
elif [ "$VOLUME" -lt 50 ]; then
  ICON="$VOLUME_LOW"
else
  ICON="$VOLUME_HIGH"
fi

sketchybar --set volume icon="$ICON" label="${VOLUME}%"
