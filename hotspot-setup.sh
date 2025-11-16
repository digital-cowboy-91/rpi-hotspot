#!/bin/bash
set -e

# This script creates the minimal Hotspot profile
# and installs a systemd service that runs it once at boot.

INSTALL_LOG="/var/log/hotspot-setup.log"
echo "[$(date)] Running hotspot-setup" >> "$INSTALL_LOG"

# ---------------------------------------------------------
# Create hotspot-init script
# ---------------------------------------------------------
cat >/usr/local/bin/hotspot-init <<'EOF'
#!/bin/bash
LOG="/var/log/hotspot-init.log"
echo "[$(date)] Initializing Hotspot profile" >> "$LOG"

nmcli connection show Hotspot >/dev/null 2>&1
EXISTS=$?

if [ $EXISTS -ne 0 ]; then
    echo "[$(date)] Hotspot not found — creating" >> "$LOG"
    nmcli connection add type wifi ifname wlan0 con-name Hotspot ssid mopidy-server
else
    echo "[$(date)] Hotspot exists — updating" >> "$LOG"
fi

nmcli connection modify Hotspot \
    802-11-wireless.mode ap \
    802-11-wireless.band bg \
    802-11-wireless-security.key-mgmt wpa-psk \
    802-11-wireless-security.psk "mopidy123" \
    ipv4.method shared \
    ipv4.addresses "192.168.100.1/24" \
    connection.autoconnect no

echo "[$(date)] Hotspot profile ready" >> "$LOG"
EOF

chmod +x /usr/local/bin/hotspot-init


# ---------------------------------------------------------
# Create systemd service that runs hotspot-init once at boot
# ---------------------------------------------------------
cat >/etc/systemd/system/hotspot-init.service <<'EOF'
[Unit]
Description=Initialize NetworkManager Hotspot profile
After=NetworkManager.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/hotspot-init

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable hotspot-init.service

echo "[$(date)] hotspot-setup completed" >> "$INSTALL_LOG"
