#!/bin/bash
# Updates the frontmost-app item (real app icon + name) whenever focus
# changes. $INFO is populated by sketchybar's built-in front_app_switched
# event with the app's name. icon.background.image="app.<name>" is a
# sketchybar built-in that fetches the app's real macOS icon.
#
# Hidden while Brave is focused — Brave lives on a real macOS Space, not an
# AeroSpace workspace, and shouldn't show up anywhere in this bar.

if [ "$SENDER" = "front_app_switched" ]; then
  if [ "$INFO" = "Brave Browser" ]; then
    sketchybar --set front_app drawing=off
  else
    sketchybar --set front_app drawing=on label="$INFO" icon.background.image="app.$INFO"
  fi
fi
