# RPI Hotspot

Small collection of scripts and units to turn a Raspberry Pi (or any Linux host with NetworkManager) into a Wi-Fi hotspot with a captive portal, web-based Wi-Fi provisioning UI, automatic hotspot failover, and log maintenance.

> All scripts assume Debian/Raspberry Pi OS–style paths and require `sudo` when touching system directories.

## Features

- **One-command install/uninstall** via `install.sh` / `uninstall.sh`.
- **Hotspot bootstrap** (`hotspot/`) creates a NetworkManager profile named `Hotspot`, exposes start/stop helpers, and installs a systemd service to ensure the profile is in place on boot.
- **Auto switcher** (`auto/`) polls `wlan0` every 15s. If normal Wi-Fi is down it starts the hotspot; once Wi-Fi reconnects it stops the hotspot.
- **Captive portal** (`portal/`) uses `nftables` plus a NetworkManager dispatcher hook to redirect all DNS/HTTP traffic from hotspot clients to the Pi.
- **Provisioning web UI** (`web/`) runs a tiny Python `http.server` on port 80 that lists nearby SSIDs and connects to the chosen network with `nmcli`.
- **Log rotation** (`logs/`) installs a systemd timer to purge `/var/log/rpi-hotspot` entries older than seven days.
- **Validation scripts**: `dry-run.sh` for repo checks and `post-install-check.sh` for verifying a live system.

## Repository Layout

```
install.sh / uninstall.sh    Top-level orchestrators
hotspot/                     Hotspot profile + controller + service
auto/                        Wi-Fi watchdog + timer
portal/                      Captive portal script + dispatcher hook
web/                         Python web UI + systemd unit
logs/                        Log cleanup script + unit + timer
dry-run.sh                   Static verification (no install)
post-install-check.sh        Sanity check after deployment
```

All subsystems follow the same pattern:

| Directory  | Setup Script | Installed Artifacts                                                                             |
| ---------- | ------------ | ----------------------------------------------------------------------------------------------- |
| `hotspot/` | `setup.sh`   | `/usr/local/bin/hotspot-init`, `/usr/local/bin/hotspot-control`, `hotspot-init.service`         |
| `auto/`    | `setup.sh`   | `/usr/local/bin/hotspot-auto`, `hotspot-auto.service`, `hotspot-auto.timer`                     |
| `portal/`  | `setup.sh`   | `/usr/local/bin/hotspot-portal`, NetworkManager dispatcher hook                                 |
| `web/`     | `setup.sh`   | `/usr/local/bin/hotspot-web.py`, `hotspot-web.service`                                          |
| `logs/`    | `setup.sh`   | `/usr/local/bin/rpi-hotspot-clean-logs`, `rpi-hotspot-clean.service`, `rpi-hotspot-clean.timer` |

Every component writes logs to `/var/log/rpi-hotspot`.

## Requirements

- Raspberry Pi OS / Debian-based distribution with NetworkManager
- `python3`, `network-manager`, and `nftables` (installed automatically by `install.sh`)
- Root privileges (run the scripts via `sudo`)

## Installation

```bash
git clone <repo> rpi-hotspot
cd rpi-hotspot
chmod +x install.sh uninstall.sh
sudo bash install.sh
```

The installer will:

1. `apt-get install` required packages
2. Create `/var/log/rpi-hotspot`
3. Run each subsystem’s `setup.sh`
4. Enable the required systemd services/timers

> Reboot after installation so NetworkManager and the hotspot profile load cleanly.

### Uninstallation

```bash
chmod +x uninstall.sh
sudo bash uninstall.sh
```

Runs every subsystem’s `uninstall.sh`, removes binaries/units, and cleans log files.

## Usage

- The **Hotspot** profile is named `Hotspot`, uses SSID `raspberry-server`, WPA-PSK `Init123*`, and shares `192.168.100.1/24`.
- The **captive portal** listens on interface `wlan0` and DNATs DNS (53) + HTTP (80) traffic to `192.168.100.1`. Disable it via `/usr/local/bin/hotspot-portal down`.
- The **web UI** is accessible at `http://192.168.100.1/` when the hotspot is active. Select an SSID, enter a password, and it will create + activate the connection by chaining `nmcli connection add` and `nmcli connection up <SSID>`.
- The **auto-switcher** keeps polling. Once the Pi successfully connects to a “normal” Wi-Fi network, it stops the hotspot automatically.

## Validation & Maintenance

| Script                  | Purpose                                                                                            | Invocation                        |
| ----------------------- | -------------------------------------------------------------------------------------------------- | --------------------------------- |
| `dry-run.sh`            | Offline validation of repo structure, shell syntax, and unit files. Runs entirely within the repo. | `bash dry-run.sh`                 |
| `post-install-check.sh` | Checks binaries, systemd units, dispatcher hook, logs, and NM profile on a live system.            | `sudo bash post-install-check.sh` |

Additional manual checks:

- `sudo systemctl status hotspot-web.service` – ensure the provisioning UI is running.
- `sudo journalctl -u hotspot-web.service -f` – tail UI logs when debugging.
- `sudo systemctl status hotspot-auto.timer` – confirm the watchdog timer is active.

## Development Notes

- All scripts are POSIX shell (`bash -n` clean). Run `bash dry-run.sh` before submitting changes.
- Logs live in `/var/log/rpi-hotspot`; the cleanup timer runs daily at 03:00.
- To redeploy a single subsystem after editing, run its `setup.sh` again (e.g., `sudo bash web/setup.sh`) and restart the related service/timer.

## Troubleshooting

- **Web UI returns connection errors**: inspect `/var/log/rpi-hotspot/hotspot-web.log` and `journalctl -u hotspot-web.service`.
- **Hotspot flaps on/off**: check `/var/log/rpi-hotspot/hotspot-auto.log` to ensure the auto-switcher sees `wlan0` state transitions correctly.
- **Captive portal not intercepting traffic**: confirm `nft list ruleset | grep hotspot_portal` and review `/var/log/rpi-hotspot/hotspot-portal.log`.

Feel free to adapt SSID, password, or interface names inside `hotspot/hotspot-init.sh` and `portal/portal.sh` if your hardware uses something other than `wlan0`.
