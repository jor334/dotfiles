#!/bin/bash
# Single-pass refresh of every AeroSpace workspace box, run by the hidden
# aerospace_controller item. Reads AeroSpace's state ONCE (one
# `list-windows --all` call + one `list-workspaces --focused` call) instead
# of querying per-workspace, so all 9 boxes update from one consistent
# snapshot — querying each box separately could catch AeroSpace mid-switch
# and show a torn/stale state for a moment.
#
# Per workspace: hides the whole box (number + app icons, grouped via a
# sketchybar bracket) when it has no windows — ignoring Brave, which the
# user keeps on a real macOS Space, not an AeroSpace workspace — pops a
# real icon in/out per open app (up to MAX_APPS_PER_SPACE placeholders
# pre-created in sketchybarrc), and animates the highlight onto the
# focused workspace's box.

source "$CONFIG_DIR/colors.sh"

MAX_APPS_PER_SPACE=4
APP_ICON_SCALE=0.75

focused=$(aerospace list-workspaces --focused)
all_workspaces=$(aerospace list-workspaces --all)
windows=$(aerospace list-windows --all --format '%{workspace}|%{app-name}' 2>/dev/null \
  | grep -v '|Brave Browser$')

for sid in $all_workspaces; do
  apps=$(echo "$windows" | awk -F'|' -v w="$sid" '$1==w {print $2}' | awk '!seen[$0]++')

  if [ -z "$apps" ]; then
    # No --animate here: the box is invisible either way, so there's
    # nothing to visually transition — just flip it off instantly.
    sketchybar --set space_bracket.$sid drawing=off background.color=$SURFACE background.border_color=$SURFACE
    sketchybar --set space.$sid drawing=off
    for slot in $(seq 0 $((MAX_APPS_PER_SPACE - 1))); do
      sketchybar --set space.$sid.app.$slot drawing=off icon.background.image.scale=0
    done
    continue
  fi

  sketchybar --set space_bracket.$sid drawing=on
  sketchybar --set space.$sid drawing=on

  if [ "$sid" = "$focused" ]; then
    sketchybar --animate tanh 8 --set space_bracket.$sid \
      background.color=$MAUVE background.border_color=$MAUVE
    sketchybar --animate tanh 8 --set space.$sid icon.color=$BASE
  else
    sketchybar --animate tanh 8 --set space_bracket.$sid \
      background.color=$SURFACE background.border_color=$SURFACE
    sketchybar --animate tanh 8 --set space.$sid icon.color=$TEXT
  fi

  i=0
  while IFS= read -r app; do
    [ "$i" -ge "$MAX_APPS_PER_SPACE" ] && break
    slot="space.$sid.app.$i"
    # Icons hidden by a previous refresh are left at scale=0, so showing
    # them again naturally pops them in — re-running this on an
    # already-visible icon is a harmless no-op animate.
    sketchybar --set "$slot" drawing=on icon.background.image="app.$app"
    sketchybar --animate tanh 10 --set "$slot" icon.background.image.scale=$APP_ICON_SCALE
    i=$((i + 1))
  done <<< "$apps"

  while [ "$i" -lt "$MAX_APPS_PER_SPACE" ]; do
    slot="space.$sid.app.$i"
    sketchybar --animate tanh 8 --set "$slot" icon.background.image.scale=0
    ( sleep 0.15 && sketchybar --set "$slot" drawing=off ) &
    i=$((i + 1))
  done
done
