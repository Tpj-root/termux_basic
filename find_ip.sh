#!/bin/bash

# Usage check
if [ -z "$1" ]; then
    echo "Usage: $0 <IP>"
    echo "Example: $0 10.30.68.1"
    exit 1
fi

# Function to scan all 255 hosts
scan_all_ip() {
    base=$(echo "$1" | awk -F. '{print $1"."$2"."$3}')
    for i in $(seq 1 255); do
        ip="$base.$i"
        ping -c 1 -W 1 "$ip" > /dev/null
        if [ $? -eq 0 ]; then
            echo "[ACTIVE] $ip"
        fi
    done
    echo "Scan completed."
}

scan_all_ip "$1"

