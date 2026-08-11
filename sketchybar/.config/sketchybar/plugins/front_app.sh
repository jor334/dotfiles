#!/bin/bash
# Updates the frontmost-app item (icon + name) whenever focus changes.
# $INFO is populated by sketchybar's built-in front_app_switched event.

if [ "$SENDER" = "front_app_switched" ]; then
  icon="$("$CONFIG_DIR/plugins/icon_map.sh" "$INFO")"
  sketchybar --set front_app icon="$icon" label="$INFO"
fi
