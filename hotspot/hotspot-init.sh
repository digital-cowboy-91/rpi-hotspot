#!/bin/bash
LOG="/var/log/rpi-hotspot/hotspot-init.log"
echo "[$(date)] Initializing Hotspot profile" >> "$LOG"

nmcli connection show Hotspot >/dev/null 2>&1
EXISTS=$?

if [ $EXISTS -ne 0 ]; then
    echo "[$(date)] Hotspot not found — creating" >> "$LOG"
    nmcli connection add type wifi ifname wlan0 con-name Hotspot ssid raspberry-hotspot
else
    echo "[$(date)] Hotspot exists — updating" >> "$LOG"
fi

nmcli connection modify Hotspot \
    802-11-wireless.mode ap \
    802-11-wireless.band bg \
    802-11-wireless-security.key-mgmt wpa-psk \
    802-11-wireless-security.psk "Init123*" \
    ipv4.method shared \
    ipv4.addresses "192.168.100.1/24" \
    connection.autoconnect no

echo "[$(date)] Hotspot profile ready" >> "$LOG"
