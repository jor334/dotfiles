#!/bin/bash
# Refreshes one or all AeroSpace workspace items: shows a strip of icons for
# the apps open in that workspace, and animates the highlight to the
# currently focused workspace.

source "$CONFIG_DIR/colors.sh"

refresh_space() {
  local sid="$1"
  local focused="$2"
  local apps icon_strip

  apps=$(aerospace list-windows --workspace "$sid" --format '%{app-name}' 2>/dev/null)
  icon_strip=""
  if [ -n "$apps" ]; then
    while IFS= read -r app; do
      icon_strip+="$("$CONFIG_DIR/plugins/icon_map.sh" "$app") "
    done <<< "$apps"
  else
    icon_strip="—"
  fi

  if [ "$sid" = "$focused" ]; then
    sketchybar --animate tanh 20 --set space.$sid \
      background.color=$MAUVE background.border_color=$MAUVE \
      icon.color=$BASE label.color=$BASE label="$icon_strip"
  else
    sketchybar --animate tanh 20 --set space.$sid \
      background.color=$SURFACE background.border_color=$SURFACE \
      icon.color=$TEXT label.color=$SUBTEXT label="$icon_strip"
  fi
}

focused=$(aerospace list-workspaces --focused)

if [ -n "$1" ]; then
  # Initial load for a single space item.
  refresh_space "$1" "$focused"
else
  # aerospace_workspace_change: refresh every workspace's icon strip and
  # move the highlight to the newly focused one.
  for sid in $(aerospace list-workspaces --all); do
    refresh_space "$sid" "$focused"
  done
fi
