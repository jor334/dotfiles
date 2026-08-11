#!/usr/bin/env bash
# Maps a running app's name to a glyph from the sketchybar-app-font
# (https://github.com/kvndrsslr/sketchybar-app-font). Used to render
# per-app icons in the workspace/front_app items instead of plain text.

function __icon_map() {
  case "$1" in
    "Warp") icon_result=":warp:" ;;
    "Brave Browser") icon_result=":brave_browser:" ;;
    "Google Chrome"|"Google Chrome Canary"|"Chromium") icon_result=":google_chrome:" ;;
    "Safari"|"Safari Technology Preview") icon_result=":safari:" ;;
    "Firefox") icon_result=":firefox:" ;;
    "Arc") icon_result=":arc:" ;;
    "Code"|"Code - Insiders") icon_result=":code:" ;;
    "Xcode") icon_result=":xcode:" ;;
    "iTerm2"|"iTerm") icon_result=":iterm:" ;;
    "Terminal") icon_result=":terminal:" ;;
    "kitty") icon_result=":kitty:" ;;
    "WezTerm") icon_result=":wezterm:" ;;
    "Alacritty") icon_result=":alacritty:" ;;
    "Finder") icon_result=":finder:" ;;
    "System Settings"|"System Preferences"|"Ajustes del Sistema") icon_result=":gear:" ;;
    "Calendar"|"Calendario"|"Fantastical") icon_result=":calendar:" ;;
    "Preview"|"Vista previa") icon_result=":pdf:" ;;
    "Notes"|"Notas") icon_result=":notes:" ;;
    "Reminders"|"Recordatorios") icon_result=":reminders:" ;;
    "Mail"|"Correo") icon_result=":mail:" ;;
    "Messages"|"Mensajes") icon_result=":messages:" ;;
    "Music"|"Música") icon_result=":music:" ;;
    "Photos"|"Fotos") icon_result=":default:" ;;
    "Maps"|"Mapas") icon_result=":maps:" ;;
    "Slack") icon_result=":slack:" ;;
    "Discord"|"Discord Canary"|"Discord PTB") icon_result=":discord:" ;;
    "Telegram") icon_result=":telegram:" ;;
    "WhatsApp") icon_result=":whats_app:" ;;
    "Messages") icon_result=":messages:" ;;
    "Mail") icon_result=":mail:" ;;
    "Notes") icon_result=":notes:" ;;
    "Notion") icon_result=":notion:" ;;
    "Obsidian") icon_result=":obsidian:" ;;
    "Figma") icon_result=":figma:" ;;
    "Spotify") icon_result=":spotify:" ;;
    "Music") icon_result=":music:" ;;
    "Preview") icon_result=":pdf:" ;;
    "Postman") icon_result=":postman:" ;;
    "Docker"|"Docker Desktop") icon_result=":docker:" ;;
    "1Password") icon_result=":one_password:" ;;
    "Zoom"|"zoom.us") icon_result=":zoom:" ;;
    "Activity Monitor") icon_result=":activity:" ;;
    "App Store") icon_result=":app_store:" ;;
    "ChatGPT") icon_result=":openai:" ;;
    "Default") icon_result=":default:" ;;
    *) icon_result=":default:" ;;
  esac
}

__icon_map "$1"
echo "$icon_result"
