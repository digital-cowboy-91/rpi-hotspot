#!/bin/bash
# hotspot/hotspot-portal-dispatcher.sh
# NetworkManager dispatcher hook for captive portal.

IFACE="$1"
STATUS="$2"
LOG="/var/log/rpi-hotspot/hotspot-portal-dispatcher.log"

echo "[$(date)] iface=$IFACE status=$STATUS" >> "$LOG"

# We only care about wlan0
if [ "$IFACE" != "wlan0" ]; then
    exit 0
fi

if [ "$STATUS" = "up" ]; then
    echo "[$(date)] wlan0 up → enabling portal" >> "$LOG"
    /usr/local/bin/hotspot-portal up >> "$LOG" 2>&1
fi

if [ "$STATUS" = "down" ]; then
    echo "[$(date)] wlan0 down → disabling portal" >> "$LOG"
    /usr/local/bin/hotspot-portal down >> "$LOG" 2>&1
fi
