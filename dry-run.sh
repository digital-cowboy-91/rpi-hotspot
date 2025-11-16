#!/bin/bash

set -e

echo "========================================"
echo "     RPI HOTSPOT — DRY RUN CHECK"
echo "========================================"

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

FAIL=0

fail() {
    echo "[FAIL] $1"
    FAIL=1
}

ok() {
    echo "[ OK ] $1"
}

echo
echo "1) Checking folder structure..."
echo "----------------------------------------"

for dir in hotspot auto portal web logs; do
    if [ -d "$dir" ]; then ok "Found directory: $dir"; 
    else fail "Missing directory: $dir"; fi
done

echo
echo "2) Checking required files exist..."
echo "----------------------------------------"

check_file() {
    if [ -f "$1" ]; then ok "Found: $1";
    else fail "Missing: $1"; fi
}

check_file hotspot/hotspot-init.sh
check_file hotspot/hotspot-control.sh
check_file hotspot/hotspot-init.service
check_file hotspot/setup.sh
check_file hotspot/uninstall.sh

check_file auto/auto.sh
check_file auto/auto.service
check_file auto/auto.timer
check_file auto/setup.sh
check_file auto/uninstall.sh

check_file portal/portal.sh
check_file portal/dispatcher.sh
check_file portal/setup.sh
check_file portal/uninstall.sh

check_file web/web.py
check_file web/web.service
check_file web/setup.sh
check_file web/uninstall.sh

check_file logs/clean.sh
check_file logs/rpi-hotspot-clean.service
check_file logs/rpi-hotspot-clean.timer
check_file logs/setup.sh
check_file logs/uninstall.sh

check_file install.sh
check_file uninstall.sh

echo
echo "3) Checking bash syntax..."
echo "----------------------------------------"

for file in $(find . -name "*.sh"); do
    if bash -n "$file"; then ok "Syntax OK: $file"
    else fail "Syntax ERROR: $file"; fi
done

echo
echo "4) Checking systemd unit syntax..."
echo "----------------------------------------"

check_unit() {
    UNIT_PATH="$(readlink -f "$1")"
    if systemd-analyze verify "$UNIT_PATH" >/dev/null 2>&1; then
        ok "Valid unit: $1"
    else
        fail "Invalid unit syntax: $1"
    fi
}

check_unit hotspot/hotspot-init.service
check_unit auto/auto.service
check_unit auto/auto.timer
check_unit web/web.service
check_unit logs/rpi-hotspot-clean.service
check_unit logs/rpi-hotspot-clean.timer

echo
echo "5) Checking log path consistency..."
echo "----------------------------------------"

if grep -R "/var/log/rpi-hotspot" -n . >/dev/null; then
    ok "All logs under /var/log/rpi-hotspot"
else
    fail "Some log paths do not use /var/log/rpi-hotspot"
fi

if grep -R "/var/log/" -n . | grep -v "/var/log/rpi-hotspot" | grep -v "/var/log/"dry-run; then
    fail "Found unexpected log paths outside rpi-hotspot directory"
else
    ok "No unexpected /var/log usage"
fi

echo
echo "6) Checking install.sh references..."
echo "----------------------------------------"

if grep -q "hotspot/setup.sh" install.sh &&
   grep -q "auto/setup.sh" install.sh &&
   grep -q "portal/setup.sh" install.sh &&
   grep -q "web/setup.sh" install.sh &&
   grep -q "logs/setup.sh" install.sh; then
    ok "install.sh references all subsystems"
else
    fail "install.sh missing subsystem references"
fi

echo
echo "7) Checking uninstall.sh references..."
echo "----------------------------------------"

if grep -q "logs/uninstall.sh" uninstall.sh &&
   grep -q "web/uninstall.sh" uninstall.sh &&
   grep -q "portal/uninstall.sh" uninstall.sh &&
   grep -q "auto/uninstall.sh" uninstall.sh &&
   grep -q "hotspot/uninstall.sh" uninstall.sh; then
    ok "uninstall.sh references all subsystems"
else
    fail "uninstall.sh missing subsystem references"
fi

echo
echo "========================================"
if [ "$FAIL" -eq 0 ]; then
    echo " DRY RUN SUCCESS — everything looks correct!"
    exit 0
else
    echo " DRY RUN FAILED — please review the errors above."
    exit 1
fi
echo "========================================"
