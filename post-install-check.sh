#!/bin/bash
# post-install-check.sh
# Validates that the full installation is running correctly on the system.

set -e

echo "========================================"
echo "   RPI HOTSPOT — POST INSTALL CHECK"
echo "========================================"

FAIL=0

fail() {
    echo "[FAIL] $1"
    FAIL=1
}

ok() {
    echo "[ OK ] $1"
}

echo
echo "1) Checking installation paths..."
echo "----------------------------------------"

check_bin() {
    if [ -x "$1" ]; then ok "Binary exists: $1"
    else fail "Binary missing or not executable: $1"; fi
}

check_bin /usr/local/bin/hotspot-init
check_bin /usr/local/bin/hotspot-control
check_bin /usr/local/bin/hotspot-auto
check_bin /usr/local/bin/hotspot-portal
check_bin /usr/local/bin/hotspot-web.py
check_bin /usr/local/bin/rpi-hotspot-clean-logs

echo
echo "2) Checking systemd services and timers..."
echo "----------------------------------------"

check_enabled() {
    if systemctl is-enabled "$1" >/dev/null 2>&1; then ok "Enabled: $1"
    else fail "Not enabled: $1"; fi
}

check_active() {
    if systemctl is-active "$1" >/dev/null 2>&1; then ok "Active: $1"
    else fail "Not active: $1"; fi
}

# Hotspot
check_enabled hotspot-init.service
check_active hotspot-init.service

# Auto
check_enabled hotspot-auto.timer
check_active hotspot-auto.timer

# Web
check_enabled hotspot-web.service
check_active hotspot-web.service

# Logs
check_enabled rpi-hotspot-clean.timer
check_active rpi-hotspot-clean.timer

echo
echo "3) Checking dispatcher script..."
echo "----------------------------------------"

if [ -x "/etc/NetworkManager/dispatcher.d/99-hotspot-portal" ]; then
    ok "Dispatcher installed"
else
    fail "Dispatcher missing or not executable"
fi

echo
echo "4) Checking log directory..."
echo "----------------------------------------"

LOG_DIR="/var/log/rpi-hotspot"

if [ -d "$LOG_DIR" ]; then ok "Log directory exists: $LOG_DIR"
else fail "Log directory missing: $LOG_DIR"; fi

echo "Checking recent logs..."
ls -l "$LOG_DIR"

# Basic sanity — logs should not be empty directory
if [ "$(ls -A "$LOG_DIR")" ]; then
    ok "Log files present"
else
    fail "No logs found — installation might not be running"
fi

echo
echo "5) Checking hotspot NetworkManager profile..."
echo "----------------------------------------"

PROFILE=$(nmcli -t -f NAME connection show | grep '^Hotspot$' || true)

if [ "$PROFILE" = "Hotspot" ]; then
    ok "Hotspot NM profile present"
else
    fail "Hotspot NM profile missing"
fi

echo
echo "6) Checking hotspot functionality (not connecting)..."
echo "----------------------------------------"

STATE=$(nmcli -t -f DEVICE,STATE d | grep "^wlan0:" || true)
echo "wlan0 state: $STATE"

# Only informational — not failing
ok "Hotspot state printed above (expected: connected or disconnected depending on network)."

echo
echo "========================================"
if [ "$FAIL" -eq 0 ]; then
    echo " POST-INSTALL CHECK PASSED ✔"
    exit 0
else
    echo " POST-INSTALL CHECK FAILED ✘"
    exit 1
fi
echo "========================================"
