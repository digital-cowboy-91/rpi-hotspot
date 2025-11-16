#!/bin/bash

set -e
LOG="/var/log/rpi-hotspot/hotspot-setup.log"

echo "[$(date)] hotspot/setup.sh starting" >> "$LOG"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

cp "$REPO_DIR/hotspot-init.sh" /usr/local/bin/hotspot-init
chmod +x /usr/local/bin/hotspot-init

cp "$REPO_DIR/hotspot-control.sh" /usr/local/bin/hotspot-control
chmod +x /usr/local/bin/hotspot-control

cp "$REPO_DIR/hotspot-init.service" /etc/systemd/system/hotspot-init.service
chmod 644 /etc/systemd/system/hotspot-init.service

systemctl daemon-reload
systemctl enable hotspot-init.service

echo "[$(date)] hotspot/setup.sh completed" >> "$LOG"
