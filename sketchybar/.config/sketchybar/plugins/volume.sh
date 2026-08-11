#!/bin/bash

VOLUME="$(osascript -e 'output volume of (get volume settings)')"

if [ "$VOLUME" -eq 0 ]; then
  ICON=""
elif [ "$VOLUME" -lt 50 ]; then
  ICON=""
else
  ICON=""
fi

sketchybar --set volume icon="$ICON" label="${VOLUME}%"
