#!/bin/bash
# web/uninstall.sh
# Removes the provisioning web UI and its systemd service

set -e
LOG="/var/log/rpi-hotspot/web-uninstall.log"

echo "[$(date)] web/uninstall.sh starting" >> "$LOG"

# Stop and disable the service
systemctl stop hotspot-web.service 2>/dev/null || true
systemctl disable hotspot-web.service 2>/dev/null || true

# Remove systemd unit
rm -f /etc/systemd/system/hotspot-web.service

systemctl daemon-reload

# Remove Python script
rm -f /usr/local/bin/hotspot-web.py

# Remove logs
rm -f /var/log/rpi-hotspot/web-setup.log
rm -f /var/log/rpi-hotspot/web-uninstall.log
rm -f /var/log/rpi-hotspot/hotspot-web.log

echo "[$(date)] web/uninstall.sh completed" >> "$LOG"
