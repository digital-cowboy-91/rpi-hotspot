#!/bin/bash
# hotspot/hotspot-portal.sh
# Simple captive portal using nftables: redirect DNS + HTTP.

TABLE="hotspot_portal"
IFACE="wlan0"
PORTAL_IP="192.168.100.1"
LOG="/var/log/hotspot-portal.log"

echo "[$(date)] portal command: $1" >> "$LOG"

case "$1" in
    up)
        echo "[$(date)] enabling portal" >> "$LOG"

        # ensure table exists
        nft list tables | grep -q "$TABLE" || nft add table ip "$TABLE"

        # ensure prerouting chain exists
        nft list chain ip "$TABLE" prerouting >/dev/null 2>&1 \
            || nft add chain ip "$TABLE" prerouting '{ type nat hook prerouting priority dstnat; }'

        # flush old rules
        nft flush chain ip "$TABLE" prerouting

        # DNS redirect → our portal IP
        nft add rule ip "$TABLE" prerouting iif "$IFACE" udp dport 53 dnat to "$PORTAL_IP"

        # HTTP redirect → our portal IP:80
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
