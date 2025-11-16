#!/bin/bash

LOG="/var/log/rpi-hotspot/hotspot-control.log"

echo "[$(date)] Command: $1" >> "$LOG"

case "$1" in
    start)
        echo "[$(date)] Starting hotspot..." >> "$LOG"
        nmcli connection up Hotspot >> "$LOG" 2>&1
        echo "[$(date)] Hotspot start complete." >> "$LOG"
        ;;
    stop)
        echo "[$(date)] Stopping hotspot..." >> "$LOG"
        nmcli connection down Hotspot >> "$LOG" 2>&1
        echo "[$(date)] Hotspot stop complete." >> "$LOG"
        ;;
    status)
        STATE=$(nmcli -t -f NAME,TYPE,DEVICE,STATE connection show --active | grep Hotspot || true)
        echo "[$(date)] Status query" >> "$LOG"
        echo "$STATE"
        ;;
    *)
        echo "Usage: hotspot-control.sh {start|stop|status}"
        exit 1
        ;;
esac
