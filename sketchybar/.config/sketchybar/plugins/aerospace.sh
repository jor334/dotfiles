#!/bin/bash
# Refreshes one or all AeroSpace workspace items: hides workspaces that have
# no windows (ignoring Brave, which the user keeps on a real macOS Space,
# not an AeroSpace workspace), shows a real icon per open app (up to
# MAX_APPS_PER_SPACE, pre-created as hidden placeholders in sketchybarrc),
# and animates the highlight onto the currently focused workspace.

source "$CONFIG_DIR/colors.sh"

MAX_APPS_PER_SPACE=4

refresh_space() {
  local sid="$1"
  local focused="$2"
  local apps
  local i=0

  apps=$(aerospace list-windows --workspace "$sid" --format '%{app-name}' 2>/dev/null \
    | grep -v '^Brave Browser$' | awk '!seen[$0]++')

  if [ -z "$apps" ]; then
    sketchybar --set space.$sid drawing=off
    for slot in $(seq 0 $((MAX_APPS_PER_SPACE - 1))); do
      sketchybar --set space.$sid.app.$slot drawing=off
    done
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

  while IFS= read -r app; do
    [ "$i" -ge "$MAX_APPS_PER_SPACE" ] && break
    sketchybar --set space.$sid.app.$i drawing=on icon.background.image="app.$app"
    i=$((i + 1))
  done <<< "$apps"

  while [ "$i" -lt "$MAX_APPS_PER_SPACE" ]; do
    sketchybar --set space.$sid.app.$i drawing=off
    i=$((i + 1))
  done
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
