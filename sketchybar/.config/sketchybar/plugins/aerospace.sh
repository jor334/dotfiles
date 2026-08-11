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
#
# IMPORTANT, two gotchas that caused stale/ghost icons before:
# 1. sketchybar reaps a script's child processes once the script exits, so
#    a detached `(sleep ... && sketchybar --set ...) &` job to finish an
#    animation-then-hide sequence never actually runs. Any shrink-then-hide
#    has to block synchronously instead; see the single `sleep` at the
#    bottom.
# 2. Workspace switches, new-window detection, and the periodic poll can
#    all fire close together. Without a lock, an older invocation (with
#    stale data, e.g. from before a new window finished opening) can
#    finish *after* a newer, correct one and clobber it. shlock makes
#    overlapping runs just skip instead of racing — the next trigger will
#    catch up.
# Wait for the lock instead of skipping when it's held: this script always
# re-reads AeroSpace's *current* state at the top, so a queued run isn't
# stale — waiting guarantees the very last trigger in a rapid burst (e.g.
# mashing workspace-switch keys) is the one that settles the display,
# instead of possibly being the one that gets dropped.
LOCKFILE="/tmp/aerospace_sketchybar_refresh.lock"
tries=0
while ! shlock -f "$LOCKFILE" -p $$; do
  tries=$((tries + 1))
  [ "$tries" -ge 40 ] && exit 0 # ~2s cap in case something's actually stuck
  sleep 0.05
done
trap 'rm -f "$LOCKFILE"' EXIT

source "$CONFIG_DIR/colors.sh"

MAX_APPS_PER_SPACE=4
APP_ICON_SCALE=0.75

focused=$(aerospace list-workspaces --focused)
all_workspaces=$(aerospace list-workspaces --all)
windows=$(aerospace list-windows --all --format '%{workspace}|%{app-name}' 2>/dev/null \
  | grep -v '|Brave Browser$')

slots_to_hide=()

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
    slots_to_hide+=("$slot")
    i=$((i + 1))
  done
done

# Give the shrink animation above time to actually play, then hide the
# slots for real — synchronously, in this same process, so it can't get
# reaped before it runs.
if [ "${#slots_to_hide[@]}" -gt 0 ]; then
  sleep 0.15
  for slot in "${slots_to_hide[@]}"; do
    sketchybar --set "$slot" drawing=off
  done
fi
