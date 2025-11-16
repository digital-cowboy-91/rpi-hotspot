#!/bin/bash
set -e

echo "========================================"
echo "        RPI Hotspot — Install"
echo "========================================"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[*] Updating apt..."
apt-get update -y

echo "[*] Installing dependencies..."
apt-get install -y python3 network-manager nftables

# Ensure log directory exists
mkdir -p /var/log/rpi-hotspot
chmod 755 /var/log/rpi-hotspot

echo "[*] Installing hotspot..."
bash "$REPO_DIR/hotspot/setup.sh"

echo "[*] Installing auto-switcher..."
bash "$REPO_DIR/auto/setup.sh"

echo "[*] Installing captive portal..."
bash "$REPO_DIR/portal/setup.sh"

echo "[*] Installing web UI..."
bash "$REPO_DIR/web/setup.sh"

echo "[*] Installing log maintenance..."
bash "$REPO_DIR/logs/setup.sh"

echo "========================================"
echo " Installation complete!"
echo "========================================"
echo ""
echo "⚠️  A reboot is required to activate the hotspot."
echo "Run: sudo reboot"
