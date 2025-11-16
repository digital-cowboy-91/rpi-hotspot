#!/bin/bash

set -e
LOG="/var/log/rpi-hotspot/auto-uninstall.log"

echo "[$(date)] auto/uninstall.sh starting" >> "$LOG"

systemctl stop hotspot-auto.timer 2>/dev/null || true
systemctl disable hotspot-auto.timer 2>/dev/null || true

systemctl stop hotspot-auto.service 2>/dev/null || true
systemctl disable hotspot-auto.service 2>/dev/null || true

rm -f /etc/systemd/system/hotspot-auto.service
rm -f /etc/systemd/system/hotspot-auto.timer

systemctl daemon-reload

rm -f /usr/local/bin/hotspot-auto

rm -f /var/log/rpi-hotspot/auto-setup.log
rm -f /var/log/rpi-hotspot/auto-uninstall.log
rm -f /var/log/rpi-hotspot/hotspot-auto.log

echo "[$(date)] auto/uninstall.sh completed" >> "$LOG"
