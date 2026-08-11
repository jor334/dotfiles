#!/bin/bash
# Updates the frontmost-app item (real app icon + name) whenever focus
# changes. $INFO is populated by sketchybar's built-in front_app_switched
# event with the app's name. icon.background.image="app.<name>" is a
# sketchybar built-in that fetches the app's real macOS icon — far more
# reliable than trying to render a glyph from a mapping font.

if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set front_app label="$INFO" icon.background.image="app.$INFO"
fi
