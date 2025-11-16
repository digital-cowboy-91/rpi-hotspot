#!/bin/bash
set -e

echo "========================================"
echo "       RPI Hotspot — Uninstall"
echo "========================================"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[*] Uninstalling web UI..."
bash "$REPO_DIR/web/uninstall.sh"

echo "[*] Uninstalling captive portal..."
bash "$REPO_DIR/portal/uninstall.sh"

echo "[*] Uninstalling auto-switcher..."
bash "$REPO_DIR/auto/uninstall.sh"

echo "[*] Uninstalling hotspot..."
bash "$REPO_DIR/hotspot/uninstall.sh"

echo "========================================"
echo " Uninstall complete!"
echo "========================================"
