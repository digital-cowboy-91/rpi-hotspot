#!/bin/bash
# auto/setup.sh
# Installs auto.sh + auto.service + auto.timer

set -e
LOG="/var/log/auto-setup.log"

echo "[$(date)] auto/setup.sh starting" >> "$LOG"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install the auto-check script
cp "$REPO_DIR/auto.sh" /usr/local/bin/hotspot-auto
chmod +x /usr/local/bin/hotspot-auto

# Install systemd units
cp "$REPO_DIR/auto.service" /etc/systemd/system/hotspot-auto.service
cp "$REPO_DIR/auto.timer"   /etc/systemd/system/hotspot-auto.timer

chmod 644 /etc/systemd/system/hotspot-auto.service
chmod 644 /etc/systemd/system/hotspot-auto.timer

systemctl daemon-reload
systemctl enable --now hotspot-auto.timer

echo "[$(date)] auto/setup.sh completed" >> "$LOG"
