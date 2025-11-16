#!/bin/bash
set -e

echo "========================================"
echo "      RPI Hotspot — Uninstall"
echo "========================================"

# Stop services/timers if they exist
systemctl stop hotspot-web.service 2>/dev/null || true
systemctl stop hotspot-auto.timer 2>/dev/null || true
systemctl stop hotspot-init.service 2>/dev/null || true

systemctl disable hotspot-web.service 2>/dev/null || true
systemctl disable hotspot-auto.timer 2>/dev/null || true
systemctl disable hotspot-init.service 2>/dev/null || true

# Remove systemd units
rm -f /etc/systemd/system/hotspot-web.service
rm -f /etc/systemd/system/hotspot-auto.service
rm -f /etc/systemd/system/hotspot-auto.timer
rm -f /etc/systemd/system/hotspot-init.service

systemctl daemon-reload

# Remove dispatcher hook
rm -f /etc/NetworkManager/dispatcher.d/99-hotspot-portal

# Remove binaries
rm -f /usr/local/bin/hotspot-init
rm -f /usr/local/bin/hotspot-control
rm -f /usr/local/bin/hotspot-auto
rm -f /usr/local/bin/hotspot-portal
rm -f /usr/local/bin/hotspot-web.py

# Remove logs
rm -f /var/log/hotspot-setup.log
rm -f /var/log/hotspot-init.log
rm -f /var/log/hotspot-control.log
rm -f /var/log/hotspot-auto.log
rm -f /var/log/hotspot-portal.log
rm -f /var/log/hotspot-portal-dispatcher.log
rm -f /var/log/hotspot-web.log

# Remove NetworkManager Hotspot profile
nmcli connection delete Hotspot 2>/dev/null || true

echo "========================================"
echo "     Uninstall complete!"
echo "========================================"