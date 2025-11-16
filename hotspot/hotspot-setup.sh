#!/bin/bash
# hotspot/hotspot-setup.sh
# Installs hotspot-init, hotspot-control, and hotspot-init.service

set -e
LOG="/var/log/hotspot-setup.log"

echo "[$(date)] Starting hotspot setup" >> "$LOG"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------------------------------------------------------
# Install hotspot-init
# ---------------------------------------------------------
echo "[$(date)] Installing hotspot-init" >> "$LOG"
cp "$REPO_DIR/hotspot-init.sh" /usr/local/bin/hotspot-init
chmod +x /usr/local/bin/hotspot-init

# ---------------------------------------------------------
# Install hotspot-control
# ---------------------------------------------------------
echo "[$(date)] Installing hotspot-control" >> "$LOG"
cp "$REPO_DIR/hotspot-control.sh" /usr/local/bin/hotspot-control
chmod +x /usr/local/bin/hotspot-control

# ---------------------------------------------------------
# Install hotspot-init.service
# ---------------------------------------------------------
echo "[$(date)] Installing hotspot-init.service" >> "$LOG"
cp "$REPO_DIR/hotspot-init.service" /etc/systemd/system/hotspot-init.service
chmod 644 /etc/systemd/system/hotspot-init.service

systemctl daemon-reload
systemctl enable hotspot-init.service

echo "[$(date)] hotspot-setup completed" >> "$LOG"
