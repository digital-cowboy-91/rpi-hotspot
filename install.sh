#!/bin/bash
set -e

echo "========================================"
echo "      RPI Hotspot — Installation"
echo "========================================"

# Directory of this repo
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[*] Updating apt..."
apt-get update -y

echo "[*] Installing dependencies..."
# python3-venv is omitted (not needed)
apt-get install -y python3 network-manager nftables

echo "[*] Running hotspot setup..."
bash "$REPO_DIR/hotspot/hotspot-setup.sh"

echo "========================================"
echo " Installation complete!"
echo "========================================"
