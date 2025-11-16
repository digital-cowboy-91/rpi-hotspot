#!/bin/bash
# hotspot/setup.sh
# Installs hotspot-init, hotspot-control, and hotspot-init.service

set -e
LOG="/var/log/hotspot-setup.log"

echo "[$(date)] hotspot/setup.sh starting" >> "$LOG"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install hotspot-init
cp "$REPO_DIR/hotspot-init.sh" /usr/local/bin/hotspot-init
chmod +x /usr/local/bin/hotspot-init

# Install hotspot-control
cp "$REPO_DIR/hotspot-control.sh" /usr/local/bin/hotspot-control
chmod +x /usr/local/bin/hotspot-control

# Install systemd service
cp "$REPO_DIR/hotspot-init.service" /etc/systemd/system/hotspot-init.service
chmod 644 /etc/systemd/system/hotspot-init.service

systemctl daemon-reload
systemctl enable hotspot-init.service

echo "[$(date)] hotspot/setup.sh completed" >> "$LOG"
