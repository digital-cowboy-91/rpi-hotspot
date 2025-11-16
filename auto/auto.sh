#!/bin/bash
# hotspot/hotspot-auto.sh
# Very small WiFi checker for low-RAM devices.
# If Wi-Fi is NOT connected → start hotspot.

LOG="/var/log/rpi-hotspot/hotspot-auto.log"

echo "[$(date)] Running auto-check" >> "$LOG"

# Check wlan0 state + active connection name
STATUS=$(nmcli -t -f DEVICE,STATE,CONNECTION dev status | grep "^wlan0:" || true)
STATE=$(echo "$STATUS" | cut -d: -f2)
CONNECTION=$(echo "$STATUS" | cut -d: -f3)

# Treat wlan0 as "needs hotspot" when it's not connected OR it's only running our Hotspot profile
if [ "$STATE" != "connected" ] || [ "$CONNECTION" = "Hotspot" ] || [ -z "$CONNECTION" ] || [ "$CONNECTION" = "--" ]; then
    echo "[$(date)] WiFi DOWN/Hotspot-needed (state=$STATE conn=$CONNECTION) → starting hotspot" >> "$LOG"
    /usr/local/bin/hotspot-control start >> "$LOG" 2>&1
else
    echo "[$(date)] WiFi OK on '$CONNECTION' → stopping hotspot (if active)" >> "$LOG"
    /usr/local/bin/hotspot-control stop >> "$LOG" 2>&1
fi
