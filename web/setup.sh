#!/bin/bash

set -e
LOG="/var/log/rpi-hotspot/web-setup.log"

echo "[$(date)] web/setup.sh starting" >> "$LOG"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

cp "$REPO_DIR/web.py" /usr/local/bin/hotspot-web.py
chmod +x /usr/local/bin/hotspot-web.py

cp "$REPO_DIR/web.service" /etc/systemd/system/hotspot-web.service
chmod 644 /etc/systemd/system/hotspot-web.service

systemctl daemon-reload
systemctl enable hotspot-web.service

echo "[$(date)] web/setup.sh completed" >> "$LOG"
