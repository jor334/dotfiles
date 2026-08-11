#!/bin/bash
# Refreshes one or all AeroSpace workspace items: hides workspaces that have
# no windows (ignoring Brave, which the user keeps on a real macOS Space,
# not an AeroSpace workspace), and animates the highlight onto the
# currently focused workspace.

source "$CONFIG_DIR/colors.sh"

refresh_space() {
  local sid="$1"
  local focused="$2"
  local apps

  apps=$(aerospace list-windows --workspace "$sid" --format '%{app-name}' 2>/dev/null | grep -v '^Brave Browser$')

  if [ -z "$apps" ]; then
    sketchybar --set space.$sid drawing=off
    return
  fi

  if [ "$sid" = "$focused" ]; then
    sketchybar --set space.$sid drawing=on
    sketchybar --animate tanh 20 --set space.$sid \
      background.color=$MAUVE background.border_color=$MAUVE icon.color=$BASE
  else
    sketchybar --set space.$sid drawing=on
    sketchybar --animate tanh 20 --set space.$sid \
      background.color=$SURFACE background.border_color=$SURFACE icon.color=$TEXT
  fi
}

focused=$(aerospace list-workspaces --focused)

if [ -n "$1" ]; then
  # Initial load for a single space item.
  refresh_space "$1" "$focused"
else
  # aerospace_workspace_change: refresh every workspace.
  for sid in $(aerospace list-workspaces --all); do
    refresh_space "$sid" "$focused"
  done
fi
