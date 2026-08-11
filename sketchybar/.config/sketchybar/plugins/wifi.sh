#!/bin/bash
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

SSID="$(ipconfig getsummary en0 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2}')"

if [ -n "$SSID" ]; then
  sketchybar --set wifi icon="$WIFI_CONNECTED" icon.color=$TEXT label="$SSID"
else
  sketchybar --set wifi icon="$WIFI_DISCONNECTED" icon.color=$SUBTEXT label="Off"
fi
