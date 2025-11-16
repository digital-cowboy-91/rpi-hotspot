#!/bin/bash
# portal/setup.sh
# Installs portal.sh + dispatcher.sh

set -e
LOG="/var/log/rpi-hotspot/portal-setup.log"

echo "[$(date)] portal/setup.sh starting" >> "$LOG"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install portal script
cp "$REPO_DIR/portal.sh" /usr/local/bin/hotspot-portal
chmod +x /usr/local/bin/hotspot-portal

# Install NetworkManager dispatcher hook
cp "$REPO_DIR/dispatcher.sh" /etc/NetworkManager/dispatcher.d/99-hotspot-portal
chmod +x /etc/NetworkManager/dispatcher.d/99-hotspot-portal

echo "[$(date)] portal/setup.sh completed" >> "$LOG"
