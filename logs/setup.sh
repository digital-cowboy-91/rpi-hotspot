#!/bin/bash

set -e
LOG="/var/log/rpi-hotspot/logs-setup.log"

echo "[$(date)] logs/setup.sh starting" >> "$LOG"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

cp "$REPO_DIR/clean.sh" /usr/local/bin/rpi-hotspot-clean-logs
chmod +x /usr/local/bin/rpi-hotspot-clean-logs

cp "$REPO_DIR/rpi-hotspot-clean.service" /etc/systemd/system/rpi-hotspot-clean.service
cp "$REPO_DIR/rpi-hotspot-clean.timer"   /etc/systemd/system/rpi-hotspot-clean.timer

chmod 644 /etc/systemd/system/rpi-hotspot-clean.service
chmod 644 /etc/systemd/system/rpi-hotspot-clean.timer

systemctl daemon-reload
systemctl enable --now rpi-hotspot-clean.timer

echo "[$(date)] logs/setup.sh completed" >> "$LOG"
