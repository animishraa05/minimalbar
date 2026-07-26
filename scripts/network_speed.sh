#!/bin/bash

# made by ani

# This script shows my network speed. Gotta know if my internet is fast enough for my memes.

# I grab the network interface. You might need to tweak this if your setup is weird.
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)

if [ -z "$INTERFACE" ]; then
    echo "N/A" # If no interface, I just say N/A. Simple.
    exit 1
fi

# I pull the raw byte counts from /proc/net/dev. This is where the magic happens.
RX_BYTES=$(grep "$INTERFACE" /proc/net/dev | awk '{print $2}')
TX_BYTES=$(grep "$INTERFACE" /proc/net/dev | awk '{print $10}')

# I store the previous values in a temp file. This helps me calculate the difference.
PREV_RX_BYTES=$(cat /tmp/polybar_prev_rx_bytes 2>/dev/null || echo 0)
PREV_TX_BYTES=$(cat /tmp/polybar_prev_tx_bytes 2>/dev/null || echo 0)

# Calculate the difference in bytes. This is how much data moved since last check.
DIFF_RX=$((RX_BYTES - PREV_RX_BYTES))
DIFF_TX=$((TX_BYTES - PREV_TX_BYTES))

# Save current values for the next round. Future me will thank me.
echo "$RX_BYTES" > /tmp/polybar_prev_rx_bytes
echo "$TX_BYTES" > /tmp/polybar_prev_tx_bytes

# Time difference matches Polybar's interval (5 seconds)
TIME_DIFF=5

# Calculate speeds in KB/s.
RX_SPEED=$(( (RX_BYTES - PREV_RX_BYTES) / 1024 / TIME_DIFF ))
TX_SPEED=$(( (TX_BYTES - PREV_TX_BYTES) / 1024 / TIME_DIFF ))

# Format the output using awk for decimal precision if needed
if [ "$RX_SPEED" -gt 1024 ] || [ "$TX_SPEED" -gt 1024 ]; then
    RX_SPEED_MB=$(awk "BEGIN {printf \"%.1f\", $RX_SPEED / 1024}")
    TX_SPEED_MB=$(awk "BEGIN {printf \"%.1f\", $TX_SPEED / 1024}")
    echo "󰇚 ${RX_SPEED_MB}MB/s 󰕒 ${TX_SPEED_MB}MB/s"
else
    echo "󰇚 ${RX_SPEED}KB/s 󰕒 ${TX_SPEED}KB/s"
fi
