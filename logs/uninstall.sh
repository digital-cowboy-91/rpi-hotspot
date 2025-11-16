#!/bin/bash
# logs/uninstall.sh
# Removes the log cleanup script, timer, and service

set -e
LOG="/var/log/rpi-hotspot/logs-uninstall.log"

echo "[$(date)] logs/uninstall.sh starting" >> "$LOG"

# ---------------------------------------------------------
# Stop and disable timer + service
# ---------------------------------------------------------
systemctl stop rpi-hotspot-clean.timer 2>/dev/null || true
systemctl disable rpi-hotspot-clean.timer 2>/dev/null || true

systemctl stop rpi-hotspot-clean.service 2>/dev/null || true
systemctl disable rpi-hotspot-clean.service 2>/dev/null || true

# ---------------------------------------------------------
# Remove systemd unit files
# ---------------------------------------------------------
rm -f /etc/systemd/system/rpi-hotspot-clean.service
rm -f /etc/systemd/system/rpi-hotspot-clean.timer

systemctl daemon-reload

# ---------------------------------------------------------
# Remove cleanup binary
# ---------------------------------------------------------
rm -f /usr/local/bin/rpi-hotspot-clean-logs

# ---------------------------------------------------------
# Remove logs from this subsystem
# ---------------------------------------------------------
rm -f /var/log/rpi-hotspot/logs-setup.log
rm -f /var/log/rpi-hotspot/logs-uninstall.log

echo "[$(date)] logs/uninstall.sh completed" >> "$LOG"
