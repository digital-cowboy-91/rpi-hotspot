#!/bin/bash
# logs/clean.sh
# Removes old logs while keeping today’s

LOG_DIR="/var/log/rpi-hotspot"

# ensure directory exists
[ -d "$LOG_DIR" ] || exit 0

# delete logs older than 7 days (configurable)
find "$LOG_DIR" -type f -mtime +7 -print -delete
