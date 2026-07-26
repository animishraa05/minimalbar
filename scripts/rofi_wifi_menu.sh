#!/bin/bash
# WiFi selector using rofi + nmcli

# Get list of available networks
NETWORKS=$(nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list | sort -t: -k2 -rn | head -20)

if [ -z "$NETWORKS" ]; then
    notify-send "WiFi" "No networks found"
    exit 0
fi

# Format for rofi (show SSID only, remove duplicates)
SSID_LIST=$(echo "$NETWORKS" | awk -F: '{print $1}' | awk '!seen[$0]++' | head -15)

# Show rofi menu
CHOICE=$(echo "$SSID_LIST" | rofi -dmenu -config ~/.config/rofi/wifi_menu.rasi -p "WiFi")

if [ -z "$CHOICE" ]; then
    exit 0
fi

# Connect to selected network
nmcli dev wifi connect "$CHOICE"
