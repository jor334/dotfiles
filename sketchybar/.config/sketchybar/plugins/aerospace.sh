#!/bin/bash
# Highlights the workspace item matching the currently focused AeroSpace workspace.

sid="$1"
focused=$(aerospace list-workspaces --focused)

if [ "$sid" = "$focused" ]; then
  sketchybar --set space.$sid background.drawing=on icon.color=0xff1e1e2e label.color=0xff1e1e2e background.color=0xffcba6f7
else
  sketchybar --set space.$sid background.drawing=off icon.color=0xffcdd6f4 label.color=0xffcdd6f4
fi
