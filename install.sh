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

echo "[*] Installing hotspot..."
bash "$REPO_DIR/hotspot/setup.sh"

echo "[*] Installing auto-switcher..."
bash "$REPO_DIR/auto/setup.sh"

echo "[*] Installing captive portal..."
bash "$REPO_DIR/portal/setup.sh"

echo "[*] Installing web UI..."
bash "$REPO_DIR/web/setup.sh"

echo "========================================"
echo " Installation complete!"
echo "========================================"
