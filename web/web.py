#!/usr/bin/env python3
# hotspot/hotspot-web.py
# Ultra-light WiFi setup web server (no Flask).

import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse
from datetime import datetime

LOG = "/var/log/rpi-hotspot/hotspot-web.log"

def log(msg):
    with open(LOG, "a") as f:
        f.write(f"[{datetime.now()}] {msg}\n")

class WiFiHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # scan SSIDs
        try:
            result = subprocess.check_output(["nmcli", "-t", "-f", "SSID", "dev", "wifi"])
            lines = result.decode().splitlines()
            ssids = [l for l in lines if l.strip() and not l.startswith("SSID:")]
        except Exception as e:
            ssids = []
            log(f"WiFi scan failed: {e}")

        # build HTML
        html = "<h1>WiFi Setup</h1>"
        html += "<form method='POST' action='/submit'>"
        html += "<select name='ssid'>"

        for ssid in ssids:
            ssid_clean = ssid.strip()
            html += f"<option value='{ssid_clean}'>{ssid_clean}</option>"

        html += "</select><br><br>"
        html += "Password: <input type='password' name='password'><br><br>"
        html += "<input type='submit' value='Connect'>"
        html += "</form>"

        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(html.encode())

    def do_POST(self):
        if self.path != "/submit":
            self.send_error(404)
            return

        length = int(self.headers.get('Content-Length', 0))
        data = self.rfile.read(length).decode()
        fields = urllib.parse.parse_qs(data)

        ssid = fields.get("ssid", [""])[0]
        password = fields.get("password", [""])[0]

        log(f"Connect request: ssid='{ssid}'")

        cmd = [
            "nmcli",
            "connection",
            "add",
            "type",
            "wifi",
            "ifname",
            "wlan0",
            "con-name",
            ssid,
            "ssid",
            ssid,
        ]

        if password:
            cmd += [
                "802-11-wireless-security.key-mgmt",
                "wpa-psk",
                "802-11-wireless-security.psk",
                password,
            ]
        else:
            cmd += [
                "802-11-wireless-security.key-mgmt",
                "none",
            ]

        result = subprocess.run(cmd, capture_output=True, text=True)
        success = (result.returncode == 0)

        if success:
            html = "<h1>Success!</h1><pre>{}</pre>".format(result.stdout)
        else:
            html = "<h1>Failed</h1><pre>{}</pre>".format(result.stderr)

        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(html.encode())

def run():
    server = HTTPServer(("0.0.0.0", 80), WiFiHandler)
    log("Web UI starting on port 80")
    server.serve_forever()

if __name__ == "__main__":
    run()
