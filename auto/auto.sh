#!/bin/bash

LOG="/var/log/rpi-hotspot/hotspot-auto.log"
MISSING_MARKER="/var/log/rpi-hotspot/.wifi-missing"
FAILOVER_DELAY_SEC=60

log() {
    echo "[$(date)] $1" >> "$LOG"
}

wifi_status() {
    local status
    status=$(nmcli -t -f DEVICE,STATE,CONNECTION dev status | grep "^wlan0:" || true)
    WIFI_STATE=$(echo "$status" | cut -d: -f2)
    WIFI_STATE_LC=$(echo "$WIFI_STATE" | tr '[:upper:]' '[:lower:]')
    WIFI_CONNECTION=$(echo "$status" | cut -d: -f3)
}

wifi_ok() {
    case "$WIFI_STATE_LC" in
        connected*)
            if [ -n "$WIFI_CONNECTION" ] && [ "$WIFI_CONNECTION" != "--" ] && [ "$WIFI_CONNECTION" != "Hotspot" ]; then
                return 0
            fi
            ;;
    esac
    return 1
}

hotspot_active() {
    if nmcli -t -f NAME connection show --active | grep -qx "Hotspot"; then
        return 0
    fi
    return 1
}

wifi_status
if hotspot_active; then
    HOTSPOT_ACTIVE=1
else
    HOTSPOT_ACTIVE=0
fi

if wifi_ok; then
    if [ "$HOTSPOT_ACTIVE" -eq 1 ]; then
        log "WiFi OK on '$WIFI_CONNECTION' → stopping hotspot"
        /usr/local/bin/hotspot-control stop >> "$LOG" 2>&1
    else
        log "WiFi OK on '$WIFI_CONNECTION' → hotspot already off"
    fi
    rm -f "$MISSING_MARKER"
    exit 0
fi

if [ "$HOTSPOT_ACTIVE" -eq 1 ]; then
    log "WiFi missing; hotspot already running"
    rm -f "$MISSING_MARKER"
    exit 0
fi

NOW=$(date +%s)
if [ ! -f "$MISSING_MARKER" ]; then
    echo "$NOW" > "$MISSING_MARKER"
    log "WiFi missing → waiting ${FAILOVER_DELAY_SEC}s before enabling hotspot"
    exit 0
fi

LAST_MISSING=$(cat "$MISSING_MARKER" 2>/dev/null || echo "$NOW")
ELAPSED=$((NOW - LAST_MISSING))

if [ "$ELAPSED" -lt "$FAILOVER_DELAY_SEC" ]; then
    exit 0
fi

log "WiFi missing for ${ELAPSED}s → starting hotspot"
rm -f "$MISSING_MARKER"
/usr/local/bin/hotspot-control start >> "$LOG" 2>&1
