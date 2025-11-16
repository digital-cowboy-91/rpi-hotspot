#!/usr/bin/env python3

import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse
from datetime import datetime
import os
import threading
import time

LOG = "/var/log/rpi-hotspot/hotspot-web.log"

TEMPLATE_DIR = "/usr/local/bin/hotspot-web-templates"
STATIC_DIR = "/usr/local/bin/hotspot-web-statics"

# ---------------------------------------
# Logging helper
# ---------------------------------------
def log(msg):
    with open(LOG, "a") as f:
        f.write(f"[{datetime.now()}] {msg}\n")

# ---------------------------------------
# Preload templates into memory
# ---------------------------------------
def load_template(name):
    try:
        with open(os.path.join(TEMPLATE_DIR, name)) as f:
            return f.read()
    except Exception as e:
        log(f"Template load failed ({name}): {e}")
        return "<h1>Template error</h1>"

INDEX_TEMPLATE = load_template("index.html")
PROCESS_TEMPLATE = load_template("processing.html")


# ---------------------------------------
# HTTP Handler
# ---------------------------------------
class WiFiHandler(BaseHTTPRequestHandler):

    def send_static(self, path):
        fs_path = os.path.join(STATIC_DIR, path.replace("/statics/", ""))

        if not os.path.exists(fs_path):
            self.send_error(404)
            return

        self.send_response(200)
        if fs_path.endswith(".css"):
            self.send_header("Content-Type", "text/css")
        elif fs_path.endswith(".ico"):
            self.send_header("Content-Type", "image/x-icon")
        self.end_headers()

        with open(fs_path, "rb") as f:
            self.wfile.write(f.read())

    # ---------------------------------------
    # GET handler
    # ---------------------------------------
    def do_GET(self):

        if self.path == "/favicon.ico":
            self.send_response(204)
            self.end_headers()
            return

        if self.path.startswith("/statics/"):
            self.send_static(self.path)
            return

        # ---------------------------------------
        # Scan WiFi networks — sorted by signal
        # ---------------------------------------
        try:
            output = subprocess.check_output(
                ["nmcli", "-t", "-f", "SSID,SIGNAL", "dev", "wifi"]
            )
            lines = output.decode().splitlines()

            networks = []
            for line in lines:
                if ":" not in line:
                    continue
                ssid, signal = line.split(":", 1)
                ssid = ssid.strip()
                signal = int(signal) if signal.isdigit() else 0

                if ssid:
                    networks.append((ssid, signal))

            # Sort by descending signal
            networks.sort(key=lambda x: x[1], reverse=True)
            ssids = [n[0] for n in networks]

        except Exception as e:
            log(f"WiFi scan failed: {e}")
            ssids = []

        options = "\n".join(
            f"<option value='{ssid}'>{ssid}</option>"
            for ssid in ssids
        )

        html = INDEX_TEMPLATE.replace("{{options}}", options)

        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(html.encode())


    # ---------------------------------------
    # POST handler
    # ---------------------------------------
    def do_POST(self):
        if self.path != "/submit":
            self.send_error(404)
            return

        length = int(self.headers.get("Content-Length", "0"))
        data = self.rfile.read(length).decode()
        fields = urllib.parse.parse_qs(data)

        ssid = fields.get("ssid", [""])[0]
        password = fields.get("password", [""])[0]

        if not ssid:
            self.send_error(400, "SSID required")
            return

        log(f"Connect request for: {ssid}")

        # ---------------------------------------
        # Serve processing screen immediately
        # ---------------------------------------
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(PROCESS_TEMPLATE.encode())

        worker = threading.Thread(
            target=connect_to_wifi,
            args=(ssid, password),
            daemon=True
        )
        worker.start()


# ---------------------------------------
# Run server
# ---------------------------------------
def connect_to_wifi(ssid, password):
    time.sleep(2)

    subprocess.run(
        ["nmcli", "connection", "delete", "id", ssid],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    cmd = [
        "nmcli", "connection", "add",
        "type", "wifi",
        "ifname", "wlan0",
        "con-name", ssid,
        "ssid", ssid
    ]

    if password:
        cmd += [
            "802-11-wireless-security.key-mgmt", "wpa-psk",
            "802-11-wireless-security.psk", password
        ]
    else:
        cmd += ["802-11-wireless-security.key-mgmt", "none"]

    add = subprocess.run(cmd, capture_output=True, text=True)
    if add.returncode != 0:
        log(f"ADD FAILED for {ssid}: {add.stderr.strip()}")
        return

    up = subprocess.run(
        ["nmcli", "connection", "up", ssid],
        capture_output=True,
        text=True
    )

    if up.returncode == 0:
        log(f"CONNECTED: {ssid}")
    else:
        log(f"CONNECT FAIL ({ssid}): {up.stderr.strip()}")


def run():
    server = HTTPServer(("0.0.0.0", 80), WiFiHandler)
    log("Web UI starting on :80")
    server.serve_forever()


if __name__ == "__main__":
    run()
