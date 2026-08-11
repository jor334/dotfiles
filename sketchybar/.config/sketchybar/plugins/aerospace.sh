#!/bin/bash
# Refreshes one AeroSpace workspace box: hides the whole box (number + app
# icons, grouped via a sketchybar bracket) when a workspace has no windows
# — ignoring Brave, which the user keeps on a real macOS Space, not an
# AeroSpace workspace — pops a real icon in/out per open app (up to
# MAX_APPS_PER_SPACE, pre-created as hidden placeholders in sketchybarrc),
# and animates the highlight onto the currently focused workspace's box.
#
# Called with a single workspace id ($1) — either at startup (one call per
# workspace) or from AeroSpace's exec-on-workspace-change (one call for the
# previously focused workspace, one for the newly focused one, fired in
# parallel), so a switch only ever touches the two boxes that actually
# changed instead of re-querying and re-animating all nine.

source "$CONFIG_DIR/colors.sh"

MAX_APPS_PER_SPACE=4
APP_ICON_SCALE=0.75
sid="$1"

apps=$(aerospace list-windows --workspace "$sid" --format '%{app-name}' 2>/dev/null \
  | grep -v '^Brave Browser$' | awk '!seen[$0]++')

if [ -z "$apps" ]; then
  sketchybar --animate tanh 8 --set space_bracket.$sid background.color=$SURFACE background.border_color=$SURFACE
  sketchybar --set space_bracket.$sid drawing=off
  sketchybar --set space.$sid drawing=off
  for slot in $(seq 0 $((MAX_APPS_PER_SPACE - 1))); do
    sketchybar --set space.$sid.app.$slot drawing=off icon.background.image.scale=0
  done
  exit 0
fi

sketchybar --set space_bracket.$sid drawing=on
sketchybar --set space.$sid drawing=on

focused=$(aerospace list-workspaces --focused)
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
  # Icons hidden by a previous refresh are left at scale=0 (see below), so
  # showing them again naturally pops them in — no extra state tracking
  # needed, and re-running this on an already-visible icon is a harmless
  # no-op animate (same start/end scale).
  sketchybar --set "$slot" drawing=on icon.background.image="app.$app"
  sketchybar --animate tanh 10 --set "$slot" icon.background.image.scale=$APP_ICON_SCALE
  i=$((i + 1))
done <<< "$apps"

while [ "$i" -lt "$MAX_APPS_PER_SPACE" ]; do
  slot="space.$sid.app.$i"
  # Pop the icon out, then hide it once it's shrunk to nothing.
  sketchybar --animate tanh 8 --set "$slot" icon.background.image.scale=0
  ( sleep 0.15 && sketchybar --set "$slot" drawing=off ) &
  i=$((i + 1))
done
