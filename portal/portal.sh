#!/bin/bash

TABLE="hotspot_portal"
IFACE="wlan0"
PORTAL_IP="192.168.100.1"
LOG="/var/log/rpi-hotspot/hotspot-portal.log"

echo "[$(date)] portal command: $1" >> "$LOG"

case "$1" in
    up)
        echo "[$(date)] enabling portal" >> "$LOG"

        nft list tables | grep -q "$TABLE" || nft add table ip "$TABLE"

        nft list chain ip "$TABLE" prerouting >/dev/null 2>&1 \
            || nft add chain ip "$TABLE" prerouting '{ type nat hook prerouting priority dstnat; }'

        nft flush chain ip "$TABLE" prerouting

        nft add rule ip "$TABLE" prerouting iif "$IFACE" udp dport 53 dnat to "$PORTAL_IP"

        nft add rule ip "$TABLE" prerouting iif "$IFACE" tcp dport 80 dnat to "$PORTAL_IP":80

        ;;
    down)
        echo "[$(date)] disabling portal" >> "$LOG"
        nft delete table ip "$TABLE" 2>/dev/null || true
        ;;
    *)
        echo "Usage: hotspot-portal.sh {up|down}"
        exit 1
        ;;
esac
