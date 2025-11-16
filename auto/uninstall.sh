#!/bin/bash
# auto/uninstall.sh
# Removes auto.sh + auto.service + auto.timer

set -e
LOG="/var/log/rpi-hotspot/auto-uninstall.log"

echo "[$(date)] auto/uninstall.sh starting" >> "$LOG"

# Stop and disable units
systemctl stop hotspot-auto.timer 2>/dev/null || true
systemctl disable hotspot-auto.timer 2>/dev/null || true

systemctl stop hotspot-auto.service 2>/dev/null || true
systemctl disable hotspot-auto.service 2>/dev/null || true

# Remove systemd units
rm -f /etc/systemd/system/hotspot-auto.service
rm -f /etc/systemd/system/hotspot-auto.timer

systemctl daemon-reload

# Remove script
rm -f /usr/local/bin/hotspot-auto

# Remove logs
rm -f /var/log/rpi-hotspot/auto-setup.log
rm -f /var/log/rpi-hotspot/auto-uninstall.log
rm -f /var/log/rpi-hotspot/hotspot-auto.log

echo "[$(date)] auto/uninstall.sh completed" >> "$LOG"
