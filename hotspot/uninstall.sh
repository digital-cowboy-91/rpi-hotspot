#!/bin/bash
# hotspot/uninstall.sh
# Removes hotspot-init, hotspot-control, and hotspot-init.service

set -e
LOG="/var/log/rpi-hotspot/hotspot-uninstall.log"

echo "[$(date)] hotspot/uninstall.sh starting" >> "$LOG"

# Stop and disable systemd service
systemctl stop hotspot-init.service 2>/dev/null || true
systemctl disable hotspot-init.service 2>/dev/null || true

# Remove systemd unit
rm -f /etc/systemd/system/hotspot-init.service

# Remove binaries
rm -f /usr/local/bin/hotspot-init
rm -f /usr/local/bin/hotspot-control

# Remove logs
rm -f /var/log/rpi-hotspot/hotspot-setup.log
rm -f /var/log/rpi-hotspot/hotspot-uninstall.log
rm -f /var/log/rpi-hotspot/hotspot-init.log
rm -f /var/log/rpi-hotspot/hotspot-control.log

# Remove NM connection if exists
nmcli connection delete Hotspot 2>/dev/null || true

systemctl daemon-reload

echo "[$(date)] hotspot/uninstall.sh completed" >> "$LOG"
