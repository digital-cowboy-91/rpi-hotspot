#!/bin/bash

LOG_DIR="/var/log/rpi-hotspot"

[ -d "$LOG_DIR" ] || exit 0

find "$LOG_DIR" -type f -mtime +7 -print -delete
