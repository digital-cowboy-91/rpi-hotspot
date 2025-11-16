#!/bin/bash

LOG="/var/log/rpi-hotspot/hotspot-auto.log"

echo "[$(date)] Running auto-check" >> "$LOG"

STATUS=$(nmcli -t -f DEVICE,STATE,CONNECTION dev status | grep "^wlan0:" || true)
STATE=$(echo "$STATUS" | cut -d: -f2)
CONNECTION=$(echo "$STATUS" | cut -d: -f3)

if [ "$STATE" = "connected" ] && [ -n "$CONNECTION" ] && [ "$CONNECTION" != "--" ] && [ "$CONNECTION" != "Hotspot" ]; then
    WIFI_OK=1
else
    WIFI_OK=0
fi

if nmcli -t -f NAME connection show --active | grep -qx "Hotspot"; then
    HOTSPOT_ACTIVE=1
else
    HOTSPOT_ACTIVE=0
fi

if [ "$WIFI_OK" -eq 1 ]; then
    if [ "$HOTSPOT_ACTIVE" -eq 1 ]; then
        echo "[$(date)] WiFi OK on '$CONNECTION' → stopping hotspot" >> "$LOG"
        /usr/local/bin/hotspot-control stop >> "$LOG" 2>&1
    else
        echo "[$(date)] WiFi OK on '$CONNECTION' → hotspot already off" >> "$LOG"
    fi
    exit 0
fi

if [ "$HOTSPOT_ACTIVE" -eq 1 ]; then
    echo "[$(date)] WiFi missing; hotspot already running" >> "$LOG"
else
    echo "[$(date)] WiFi missing; starting hotspot" >> "$LOG"
    /usr/local/bin/hotspot-control start >> "$LOG" 2>&1
fi
