#!/bin/bash
# portal/uninstall.sh
# Removes portal.sh + dispatcher hook

set -e
LOG="/var/log/rpi-hotspot/portal-uninstall.log"

echo "[$(date)] portal/uninstall.sh starting" >> "$LOG"

# Remove dispatcher hook
rm -f /etc/NetworkManager/dispatcher.d/99-hotspot-portal

# Remove portal binary
rm -f /usr/local/bin/hotspot-portal

# Remove logs
rm -f /var/log/rpi-hotspot/portal-setup.log
rm -f /var/log/rpi-hotspot/portal-uninstall.log
rm -f /var/log/rpi-hotspot/hotspot-portal.log
rm -f /var/log/rpi-hotspot/hotspot-portal-dispatcher.log

echo "[$(date)] portal/uninstall.sh completed" >> "$LOG"
