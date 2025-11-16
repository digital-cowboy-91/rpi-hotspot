#!/bin/bash

set -e
LOG="/var/log/rpi-hotspot/web-uninstall.log"

echo "[$(date)] web/uninstall.sh starting" >> "$LOG"

systemctl stop hotspot-web.service 2>/dev/null || true
systemctl disable hotspot-web.service 2>/dev/null || true

rm -f /etc/systemd/system/hotspot-web.service

systemctl daemon-reload

rm -f /usr/local/bin/hotspot-web.py

rm -f /var/log/rpi-hotspot/web-setup.log
rm -f /var/log/rpi-hotspot/web-uninstall.log
rm -f /var/log/rpi-hotspot/hotspot-web.log

echo "[$(date)] web/uninstall.sh completed" >> "$LOG"
