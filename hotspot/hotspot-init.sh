#!/bin/bash
# hotspot/hotspot-init.sh
# Create or update the minimal NetworkManager Hotspot profile.

LOG="/var/log/hotspot-init.log"
echo "[$(date)] Initializing Hotspot profile" >> "$LOG"

nmcli connection show Hotspot >/dev/null 2>&1
EXISTS=$?

if [ $EXISTS -ne 0 ]; then
    echo "[$(date)] Hotspot not found — creating" >> "$LOG"
    nmcli connection add type wifi ifname wlan0 con-name Hotspot ssid mopidy-server
else
    echo "[$(date)] Hotspot exists — updating" >> "$LOG"
fi

nmcli connection modify Hotspot \
    802-11-wireless.mode ap \
    802-11-wireless.band bg \
    802-11-wireless-security.key-mgmt wpa-psk \
    802-11-wireless-security.psk "mopidy123" \
    ipv4.method shared \
    ipv4.addresses "192.168.100.1/24" \
    connection.autoconnect no

echo "[$(date)] Hotspot profile ready" >> "$LOG"
