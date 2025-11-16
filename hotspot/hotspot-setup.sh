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

# ---------------------------------------------------------
# Install hotspot-auto script
# ---------------------------------------------------------
echo "[$(date)] Installing hotspot-auto" >> "$LOG"
cp "$REPO_DIR/hotspot-auto.sh" /usr/local/bin/hotspot-auto
chmod +x /usr/local/bin/hotspot-auto

# ---------------------------------------------------------
# Install auto hotspot systemd service + timer
# ---------------------------------------------------------
echo "[$(date)] Installing hotspot-auto.service & timer" >> "$LOG"
cp "$REPO_DIR/hotspot-auto.service" /etc/systemd/system/hotspot-auto.service
cp "$REPO_DIR/hotspot-auto.timer" /etc/systemd/system/hotspot-auto.timer

chmod 644 /etc/systemd/system/hotspot-auto.service
chmod 644 /etc/systemd/system/hotspot-auto.timer

# ---------------------------------------------------------
# Install hotspot-portal script
# ---------------------------------------------------------
echo "[$(date)] Installing hotspot-portal" >> "$LOG"
cp "$REPO_DIR/hotspot-portal.sh" /usr/local/bin/hotspot-portal
chmod +x /usr/local/bin/hotspot-portal

# ---------------------------------------------------------
# Install NetworkManager dispatcher hook for captive portal
# ---------------------------------------------------------
echo "[$(date)] Installing hotspot-portal dispatcher" >> "$LOG"
cp "$REPO_DIR/hotspot-portal-dispatcher.sh" /etc/NetworkManager/dispatcher.d/99-hotspot-portal
chmod +x /etc/NetworkManager/dispatcher.d/99-hotspot-portal

# ---------------------------------------------------------
# Enable services
# ---------------------------------------------------------
systemctl daemon-reload
systemctl enable hotspot-init.service
systemctl enable --now hotspot-auto.timer

echo "[$(date)] hotspot-setup completed" >> "$LOG"
