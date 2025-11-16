#!/bin/bash

set -e
LOG="/var/log/rpi-hotspot/portal-setup.log"

echo "[$(date)] portal/setup.sh starting" >> "$LOG"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

cp "$REPO_DIR/portal.sh" /usr/local/bin/hotspot-portal
chmod +x /usr/local/bin/hotspot-portal

cp "$REPO_DIR/dispatcher.sh" /etc/NetworkManager/dispatcher.d/99-hotspot-portal
chmod +x /etc/NetworkManager/dispatcher.d/99-hotspot-portal

echo "[$(date)] portal/setup.sh completed" >> "$LOG"
