#!/bin/bash
# hotspot/hotspot-auto.sh
# Very small WiFi checker for low-RAM devices.
# If Wi-Fi is NOT connected → start hotspot.

LOG="/var/log/hotspot-auto.log"

echo "[$(date)] Running auto-check" >> "$LOG"

# Check if wlan0 is connected
CONNECTED=$(nmcli -t -f DEVICE,STATE d | grep "^wlan0:connected" || true)

if [ -z "$CONNECTED" ]; then
    echo "[$(date)] WiFi DOWN → starting hotspot" >> "$LOG"
    /usr/local/bin/hotspot-control start >> "$LOG" 2>&1
else
    echo "[$(date)] WiFi OK → stopping hotspot (if active)" >> "$LOG"
    /usr/local/bin/hotspot-control stop >> "$LOG" 2>&1
fi
