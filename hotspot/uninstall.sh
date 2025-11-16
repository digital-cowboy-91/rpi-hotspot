#!/bin/bash

set -e
LOG="/var/log/rpi-hotspot/hotspot-uninstall.log"

echo "[$(date)] hotspot/uninstall.sh starting" >> "$LOG"

systemctl stop hotspot-init.service 2>/dev/null || true
systemctl disable hotspot-init.service 2>/dev/null || true

rm -f /etc/systemd/system/hotspot-init.service

rm -f /usr/local/bin/hotspot-init
rm -f /usr/local/bin/hotspot-control

rm -f /var/log/rpi-hotspot/hotspot-setup.log
rm -f /var/log/rpi-hotspot/hotspot-uninstall.log
rm -f /var/log/rpi-hotspot/hotspot-init.log
rm -f /var/log/rpi-hotspot/hotspot-control.log

nmcli connection delete Hotspot 2>/dev/null || true

systemctl daemon-reload

echo "[$(date)] hotspot/uninstall.sh completed" >> "$LOG"
